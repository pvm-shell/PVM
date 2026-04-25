package main

import (
	"archive/zip"
	"crypto/sha256"
	"encoding/hex"
	"encoding/json"
	"fmt"
	"io"
	"net/http"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

var (
	VERSION = "0.1.0-alpha"
	PVM_DIR = ""
)

func init() {
	PVM_DIR = os.Getenv("LOCALAPPDATA") + "\\pvm"
	os.MkdirAll(PVM_DIR, 0755)
	os.MkdirAll(filepath.Join(PVM_DIR, "versions"), 0755)
	os.MkdirAll(filepath.Join(PVM_DIR, "cache"), 0755)
	os.MkdirAll(filepath.Join(PVM_DIR, "alias"), 0755)
}

func main() {
	if len(os.Args) < 2 {
		help()
		return
	}

	cmd := os.Args[1]
	args := os.Args[2:]

	switch cmd {
	case "help":
		help()
	case "current":
		current()
	case "system":
		system()
	case "install":
		install(args)
	case "list", "ls":
		list(args)
	case "use":
		use(args)
	case "uninstall":
		uninstall(args)
	case "root":
		fmt.Println("PVM Root:", PVM_DIR)
	case "version":
		if len(args) > 0 && args[0] == "--check" {
			checkVersion()
		} else {
			fmt.Println("PVM Version:", VERSION)
		}
	case "doctor":
		doctor()
	case "verify":
		if len(args) < 2 {
			fmt.Println("Usage: pvm verify <filepath> <expected_hash>")
			return
		}
		verifyBinary(args[0], args[1])
	default:
		fmt.Printf("Unknown command: %s\n", cmd)
		help()
	}
}

func help() {
	fmt.Printf("Running PVM version %s.\n\n", VERSION)
	fmt.Println("Usage:")
	fmt.Println("  pvm current                    : Display active Python version.")
	fmt.Println("  pvm system                     : Display system Python version.")
	fmt.Println("  pvm install <version> [arch]   : Install a Python version.")
	fmt.Println("  pvm list [available]           : List installed Python versions.")
	fmt.Println("  pvm use <version> [arch]       : Switch to the specified Python version.")
	fmt.Println("  pvm uninstall <version>        : Remove a Python version.")
	fmt.Println("  pvm root [path]                : Show the PVM root directory.")
	fmt.Println("  pvm version [--check]          : Display PVM version or check for updates.")
	fmt.Println("  pvm doctor                     : Run environment diagnostics.")
	fmt.Println("  pvm verify <file> <hash>       : Verify file integrity using SHA-256.")
}

func current() {
	currentPath := filepath.Join(PVM_DIR, "current")
	link, err := os.Readlink(currentPath)
	if err != nil {
		fmt.Println("No version currently in use.")
		return
	}
	fmt.Printf("Current version: %s\n", filepath.Base(link))
}

func doctor() {
	pvmCurrent := filepath.Join(PVM_DIR, "current")

	// 1. PVM current is first in PATH
	pathEnv := os.Getenv("PATH")
	paths := strings.Split(pathEnv, ";")
	if len(paths) > 0 && strings.EqualFold(paths[0], pvmCurrent) {
		fmt.Println("PVM current is first in PATH: OK")
	} else {
		fmt.Println("PVM current is first in PATH: FAIL")
	}

	// 2. Python resolves to PVM
	cmd := exec.Command("where", "python")
	output, err := cmd.Output()
	if err == nil {
		lines := strings.Split(strings.TrimSpace(string(output)), "\r\n")
		if len(lines) > 0 && strings.Contains(strings.ToLower(lines[0]), strings.ToLower(pvmCurrent)) {
			fmt.Println("Python resolves to PVM: OK")
		} else {
			fmt.Println("Python resolves to PVM: FAIL")
		}
	} else {
		fmt.Println("Python resolves to PVM: FAIL (python not found)")
	}

	// 3. Current version
	link, err := os.Readlink(pvmCurrent)
	if err == nil {
		fmt.Printf("Current version: %s\n", filepath.Base(link))
	} else {
		fmt.Println("Current version: None")
	}
}

func system() {
	// Find python.exe using 'where python'
	cmd := exec.Command("cmd", "/c", "where", "python")
	output, err := cmd.CombinedOutput()
	if err != nil {
		fmt.Println("No system Python found.")
		return
	}

	lines := strings.Split(string(output), "\r\n")
	found := false
	pvmCurrent := strings.ToLower(filepath.Join(PVM_DIR, "current"))

	for _, path := range lines {
		if path == "" {
			continue
		}
		if !strings.Contains(strings.ToLower(path), pvmCurrent) {
			fmt.Printf("Path: %s\n", path)
			vcmd := exec.Command(path, "--version")
			voutput, _ := vcmd.CombinedOutput()
			fmt.Printf("System Python: %s", string(voutput))
			found = true
			break
		}
	}

	if !found {
		fmt.Println("No system Python found outside of PVM.")
	}
}

func install(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: pvm install <version>")
		return
	}
	version := args[0]
	targetDir := filepath.Join(PVM_DIR, "versions", version)

	if _, err := os.Stat(targetDir); err == nil {
		fmt.Printf("Version %s already installed.\n", version)
		return
	}

	// Download embeddable zip
	url := fmt.Sprintf("https://www.python.org/ftp/python/%s/python-%s-embed-amd64.zip", version, version)
	zipPath := filepath.Join(PVM_DIR, "cache", fmt.Sprintf("python-%s.zip", version))

	fmt.Printf("Downloading Python %s...\n", version)
	err := downloadFile(zipPath, url)
	if err != nil {
		fmt.Printf("Download failed: %v\n", err)
		return
	}

	fmt.Printf("Extracting to %s...\n", targetDir)
	err = unzip(zipPath, targetDir)
	if err != nil {
		fmt.Printf("Extraction failed: %v\n", err)
		return
	}

	fmt.Printf("Successfully installed Python %s\n", version)
}

func list(_ []string) {
	versionsDir := filepath.Join(PVM_DIR, "versions")
	files, err := os.ReadDir(versionsDir)
	if err != nil {
		fmt.Println("No versions installed.")
		return
	}

	for _, f := range files {
		if f.IsDir() {
			fmt.Println(f.Name())
		}
	}
}

func use(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: pvm use <version>")
		return
	}
	version := args[0]

	if version == "system" {
		currentPath := filepath.Join(PVM_DIR, "current")
		os.RemoveAll(currentPath)
		fmt.Println("Now using system Python")
		system()
		return
	}

	targetDir := filepath.Join(PVM_DIR, "versions", version)

	if _, err := os.Stat(targetDir); os.IsNotExist(err) {
		fmt.Printf("Version %s is not installed.\n", version)
		return
	}

	currentPath := filepath.Join(PVM_DIR, "current")
	
	// Remove existing junction
	os.RemoveAll(currentPath)

	// Create junction using cmd (mklink /j)
	fmt.Printf("Switching to Python %s...\n", version)
	cmd := exec.Command("cmd", "/c", "mklink", "/j", currentPath, targetDir)
	err := cmd.Run()
	if err != nil {
		fmt.Printf("Failed to create junction: %v\n", err)
		return
	}

	fmt.Printf("Now using Python %s\n", version)
	fmt.Println("Note: Ensure %LOCALAPPDATA%\\pvm\\current is in your PATH.")
}

func uninstall(args []string) {
	if len(args) < 1 {
		fmt.Println("Usage: pvm uninstall <version>")
		return
	}
	version := args[0]
	targetDir := filepath.Join(PVM_DIR, "versions", version)
	
	err := os.RemoveAll(targetDir)
	if err != nil {
		fmt.Printf("Failed to uninstall: %v\n", err)
		return
	}
	fmt.Printf("Uninstalled Python %s\n", version)
}

func downloadFile(outputPath string, url string) error {
	// Try local bundled aria2c first
	localAria := filepath.Join(PVM_DIR, "aria2", "aria2c.exe")
	if _, err := os.Stat(localAria); err == nil {
		fmt.Println("Using bundled aria2c for parallel download...")
		cmd := exec.Command(localAria, "-x", "16", "-s", "16", "-k", "1M", "-o", filepath.Base(outputPath), "-d", filepath.Dir(outputPath), url)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	}

	// Try aria2c in PATH
	if _, err := exec.LookPath("aria2c"); err == nil {
		fmt.Println("Using system aria2c for parallel download...")
		cmd := exec.Command("aria2c", "-x", "16", "-s", "16", "-k", "1M", "-o", filepath.Base(outputPath), "-d", filepath.Dir(outputPath), url)
		cmd.Stdout = os.Stdout
		cmd.Stderr = os.Stderr
		return cmd.Run()
	}

	// Fallback to native Go http download
	resp, err := http.Get(url)
	if err != nil {
		return err
	}
	defer resp.Body.Close()

	out, err := os.Create(outputPath)
	if err != nil {
		return err
	}
	defer out.Close()

	_, err = io.Copy(out, resp.Body)
	return err
}

func unzip(src, dest string) error {
	r, err := zip.OpenReader(src)
	if err != nil {
		return err
	}
	defer r.Close()

	os.MkdirAll(dest, 0755)

	for _, f := range r.File {
		fpath := filepath.Join(dest, f.Name)
		if f.FileInfo().IsDir() {
			os.MkdirAll(fpath, os.ModePerm)
			continue
		}

		if err = os.MkdirAll(filepath.Dir(fpath), os.ModePerm); err != nil {
			return err
		}

		outFile, err := os.OpenFile(fpath, os.O_WRONLY|os.O_CREATE|os.O_TRUNC, f.Mode())
		if err != nil {
			return err
		}

		rc, err := f.Open()
		if err != nil {
			return err
		}

		_, err = io.Copy(outFile, rc)
		outFile.Close()
		rc.Close()

		if err != nil {
			return err
		}
	}
	return nil
}

func getLatestTag(url string, key string) string {
	resp, err := http.Get(url)
	if err != nil {
		return ""
	}
	defer resp.Body.Close()

	if resp.StatusCode != http.StatusOK {
		return ""
	}

	var data interface{}
	if err := json.NewDecoder(resp.Body).Decode(&data); err != nil {
		return ""
	}

	if key == "tag_name" {
		// Response for /releases/latest is an object
		if m, ok := data.(map[string]interface{}); ok {
			if v, ok := m["tag_name"].(string); ok {
				return v
			}
		}
	} else if key == "name" {
		// Response for /tags is an array
		if slice, ok := data.([]interface{}); ok && len(slice) > 0 {
			if m, ok := slice[0].(map[string]interface{}); ok {
				if v, ok := m["name"].(string); ok {
					return v
				}
			}
		}
	}
	return ""
}

func checkVersion() {
	fmt.Println("Checking for PVM updates...")
	
	// 1. Try /releases/latest
	latestTag := getLatestTag("https://api.github.com/repos/pvm-shell/PVM/releases/latest", "tag_name")
	
	// 2. Fallback to /tags
	if latestTag == "" {
		latestTag = getLatestTag("https://api.github.com/repos/pvm-shell/PVM/tags", "name")
	}

	if latestTag == "" {
		fmt.Println("Could not determine latest version.")
		return
	}

	if latestTag != "v"+VERSION {
		fmt.Printf("New version available: %s (Current: v%s)\n", latestTag, VERSION)
	} else {
		fmt.Printf("PVM is up to date: %s\n", latestTag)
	}
}

func verifyBinary(path, expectedHash string) {
	fmt.Printf("Verifying %s...\n", path)
	f, err := os.Open(path)
	if err != nil {
		fmt.Printf("Error opening file: %v\n", err)
		return
	}
	defer f.Close()

	h := sha256.New()
	if _, err := io.Copy(h, f); err != nil {
		fmt.Printf("Error calculating hash: %v\n", err)
		return
	}

	actualHash := hex.EncodeToString(h.Sum(nil))
	fmt.Printf("Actual SHA-256: %s\n", actualHash)
	fmt.Printf("Expected SHA-256: %s\n", strings.ToLower(expectedHash))

	if strings.EqualFold(actualHash, expectedHash) {
		fmt.Println("✅ Verification SUCCESS: Hashes match!")
	} else {
		fmt.Println("❌ Verification FAILED: Hashes do NOT match!")
		os.Exit(1)
	}
}
