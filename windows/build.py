import os
import subprocess
import sys
import glob

# --- Configuration ---
PFX_PASS = "ueo586_crty555"
# Try a few common locations for Windows Kits
SDK_PATHS = [
    r"C:\Program Files (x86)\Windows Kits\10\bin",
    r"C:\Program Files (x86)\Windows Kits\8.1\bin",
    r"C:\Program Files\Windows Kits\10\bin"
]
ISCC_PATH = r"C:\Program Files (x86)\Inno Setup 6\ISCC.exe"
GH_REPO = "pvm-shell/PVM"

def find_tool(name):
    """Finds a tool using PowerShell (most robust)."""
    # 1. Hardcoded fallback (known to exist)
    known = f"C:/Program Files (x86)/Windows Kits/10/bin/10.0.26100.0/x64/{name}"
    if os.path.exists(known):
        return known

    # 2. Dynamic lookup via PowerShell
    for base in SDK_PATHS:
        if not os.path.exists(base):
            continue
        try:
            cmd = f'powershell -Command "(Get-ChildItem -Path \'{base}\' -Filter \'{name}\' -Recurse -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName -First 1)"'
            result = subprocess.run(cmd, capture_output=True, text=True, shell=True)
            path = result.stdout.strip()
            if path and os.path.exists(path):
                return path
        except:
            continue
    return None

def get_signtool():
    """Finds the latest signtool.exe."""
    tool = find_tool("signtool.exe")
    if not tool:
        print("Warning: signtool.exe not found.")
        return None
    return tool

def compile_resources():
    """Compiles .rc into .syso for Go to link."""
    rc_path = find_tool("rc.exe")
    cvtres_path = find_tool("cvtres.exe")
    
    if not rc_path or not cvtres_path:
        print("Warning: rc.exe or cvtres.exe not found. Binary metadata will be missing.")
        return False
    
    print(f"Using rc: {rc_path}")
    print(f"Using cvtres: {cvtres_path}")
    try:
        # rc /fo pvm.res pvm.rc
        subprocess.run([str(rc_path), "/fo", "pvm.res", "pvm.rc"], check=True)
        # cvtres /machine:x64 /out:pvm_res.syso pvm.res
        subprocess.run([str(cvtres_path), "/machine:x64", "/out:pvm_res.syso", "pvm.res"], check=True)
        print("Successfully compiled resources into pvm_res.syso")
        return True
    except subprocess.CalledProcessError as e:
        print(f"Warning: Resource compilation failed: {e}")
        return False

def sign_file(file_path, pfx_path):
    """Signs a file using signtool.exe."""
    signtool = get_signtool()
    if not signtool:
        print(f"Warning: Skipping signing for {file_path} (signtool not found)")
        return

    print(f"Signing {file_path}...")
    cmd = [
        str(signtool), "sign", "/f", str(pfx_path), "/p", PFX_PASS,
        "/tr", "http://timestamp.digicert.com", "/td", "sha256", "/fd", "sha256",
        file_path
    ]
    try:
        subprocess.run(cmd, check=True)
        print(f"Successfully signed {file_path}")
    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to sign {file_path}: {e}")
        sys.exit(1)

def build_go():
    """Compiles the Go source into pvm.exe."""
    print("Compiling pvm.go...")
    # -ldflags "-s -w" reduces binary size
    cmd = ["go", "build", "-ldflags", "-s -w", "-o", "pvm.exe", "pvm.go"]
    try:
        subprocess.run(cmd, check=True)
        print("Successfully compiled pvm.exe")
    except subprocess.CalledProcessError as e:
        print(f"Error: Go build failed: {e}")
        sys.exit(1)

def build_installer():
    """Compiles the Inno Setup installer."""
    if not os.path.exists(ISCC_PATH):
        print(f"Error: Inno Setup (ISCC.exe) not found at {ISCC_PATH}")
        sys.exit(1)
    
    print("Building Inno Setup installer...")
    cmd = [ISCC_PATH, "pvm-setup.iss"]
    try:
        subprocess.run(cmd, check=True)
        print("Successfully built installer")
    except subprocess.CalledProcessError as e:
        print(f"Error: Inno Setup build failed: {e}")
        sys.exit(1)

def get_pfx():
    """Finds a .pfx file in standard locations or provided path."""
    # 1. Check user provided path
    user_pfx = r"C:\Users\LenovoPC\cert.pfx"
    if os.path.exists(user_pfx):
        return user_pfx

    # 2. Check current directory
    pfx_files = glob.glob("*.pfx")
    if pfx_files:
        return pfx_files[0]
        
    print("Warning: No .pfx file found. Skipping signing.")
    return None

def main():
    # 0. Compile Resources
    has_res = compile_resources()

    # 1. Build Go binary
    build_go()

    # Clean up temporary resource files after Go build
    if os.path.exists("pvm.res"): os.remove("pvm.res")
    if os.path.exists("pvm_res.syso"): os.remove("pvm_res.syso")

    # 2. Sign Go binary if PFX exists
    pfx = get_pfx()
    if pfx:
        sign_file("pvm.exe", pfx)

    # 3. Build Installer
    build_installer()

    # 4. Sign Installer if PFX exists
    # Based on OutputDir=. and OutputBaseFilename=pvm-setup in pvm-setup.iss
    installer_path = "pvm-setup.exe"
    if pfx and os.path.exists(installer_path):
        sign_file(installer_path, pfx)

    print("\n--- Build Complete ---")
    if pfx:
        print("Files are signed and ready for release.")
    else:
        print("Files are built but NOT signed (missing .pfx).")
    
    if has_res:
        print("Binary metadata and icon were embedded successfully.")

    # Optional GitHub Release logic
    if len(sys.argv) > 1 and sys.argv[1] == "--release":
        release_ver = input("Enter release version (e.g., v0.1.0): ")
        print(f"Creating GitHub release {release_ver}...")
        gh_cmd = ["gh", "release", "create", release_ver, "pvm-setup.exe", "--repo", GH_REPO, "--notes", "New PVM Release"]
        try:
            subprocess.run(gh_cmd, check=True)
            print("GitHub release created successfully!")
        except Exception as e:
            print(f"Error: GitHub release failed: {e}. Ensure 'gh' CLI is installed and authenticated.")

if __name__ == "__main__":
    main()
