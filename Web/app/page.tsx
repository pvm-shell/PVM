"use client";

import React, { useState } from "react";
import Image from "next/image";
import { motion } from "framer-motion";
import { 
  Search, 
  Github, 
  Terminal, 
  Download, 
  Book, 
  Users, 
  Newspaper,
  ChevronRight,
  Shield, 
  FileText, 
  HelpCircle, 
  ExternalLink, 
  Copy, 
  Check, 
  Info
} from "lucide-react";
import { cn } from "@/lib/utils";

// --- Sub-components ---

const PrimaryNav = () => (
  <nav className="nav-primary px-8 py-3 flex items-center justify-between text-white border-b border-black/20">
    <div className="flex items-center gap-6">
      <a href="https://pvm.is-best.net" className="flex items-center gap-3 hover:opacity-80 transition-opacity">
        <Image src="/pvm_logo-removebg.png" alt="PVM Logo" width={32} height={32} />
        <span className="font-bold text-xl tracking-tight">PVM</span>
      </a>
      <div className="hidden lg:flex gap-1">
        <a href="#" className="nav-link">About</a>
        <a href="#" className="nav-link">Downloads</a>
        <a href="#" className="nav-link">Documentation</a>
        <a href="#" className="nav-link">Community</a>
        <a href="#" className="nav-link">News</a>
      </div>
    </div>
    <div className="flex items-center gap-4">
      <div className="relative hidden md:block">
        <input 
          type="text" 
          placeholder="Search..." 
          className="bg-navy-dark border border-white/20 rounded px-3 py-1 text-xs focus:ring-1 focus:ring-gold outline-none w-48"
        />
        <Search className="w-3 h-3 absolute right-3 top-2 text-slate-500" />
      </div>
      <a href="https://github.com/pvm-shell/PVM" className="bg-navy-light/50 px-3 py-1 rounded text-xs font-bold hover:bg-navy-light transition-colors flex items-center gap-2">
        <Github className="w-4 h-4" /> REPO
      </a>
    </div>
  </nav>
);

const SecondaryNav = () => (
  <nav className="nav-secondary px-8 py-1 flex items-center gap-8 self-start w-full shadow-inner overflow-x-auto whitespace-nowrap">
    <a href="#overview" className="text-[11px] text-white/70 font-bold uppercase hover:text-gold transition-colors py-2 border-b-2 border-transparent hover:border-gold">Overview</a>
    <a href="#install" className="text-[11px] text-white/70 font-bold uppercase hover:text-gold transition-colors py-2 border-b-2 border-transparent hover:border-gold">Install</a>
    <a href="#commands" className="text-[11px] text-white/70 font-bold uppercase hover:text-gold transition-colors py-2 border-b-2 border-transparent hover:border-gold">Commands</a>
    <a href="#releases" className="text-[11px] text-white/70 font-bold uppercase hover:text-gold transition-colors py-2 border-b-2 border-transparent hover:border-gold">Releases</a>
    <a href="#security" className="text-[11px] text-white/70 font-bold uppercase hover:text-gold transition-colors py-2 border-b-2 border-transparent hover:border-gold">Security</a>
  </nav>
);

const CodeSnippet = ({ code }: { code: string }) => {
  const [copied, setCopied] = useState(false);
  return (
    <div className="code-box group">
      <span className="text-gold mr-2">$</span>
      <span>{code}</span>
      <button 
        onClick={() => {
          navigator.clipboard.writeText(code);
          setCopied(true);
          setTimeout(() => setCopied(false), 2000);
        }}
        className="absolute right-4 opacity-0 group-hover:opacity-100 transition-opacity"
      >
        {copied ? <Check className="w-4 h-4 text-green-500" /> : <Copy className="w-4 h-4 text-slate-500" />}
      </button>
    </div>
  );
};

export default function Home() {
  return (
    <div className="min-h-screen bg-background">
      <PrimaryNav />
      <SecondaryNav />

      {/* Hero / Download Section */}
      <section className="bg-navy-dark text-white py-16 px-8 border-b border-white/5">
        <div className="max-w-6xl mx-auto flex flex-col md:flex-row items-center justify-between gap-12">
          <div className="max-w-2xl text-center md:text-left">
            <h1 className="text-4xl font-bold mb-4 tracking-tight">Download PVM for Python</h1>
            <p className="text-xl text-slate-400 mb-8">
              Manage multiple Python versions with a lightweight POSIX-first workflow. Simple, fast, and transparent.
            </p>
            <div className="flex flex-col sm:flex-row gap-4 mb-8 justify-center md:justify-start">
              <button className="btn-pvm">Download PVM 0.1.0-alpha</button>
              <button className="px-8 py-3 border border-white/20 rounded font-bold hover:bg-white/5 transition-all text-lg">
                View install instructions
              </button>
            </div>
            <div className="max-w-xl mx-auto md:mx-0">
              <CodeSnippet code="curl -o- https://raw.githubusercontent.com/pvm-shell/PVM/main/install.sh | bash" />
            </div>
            <p className="mt-6 text-sm text-slate-500">
              <Info className="w-4 h-4 inline mr-2 text-gold" />
              Looking for Windows? Native Windows support is in development. 
              <a href="#" className="text-blue-400 hover:underline ml-1">WSL is supported</a>.
            </p>
          </div>
          <div className="hidden lg:block w-72 h-72 relative opacity-20">
             <Image src="/pvm_logo-removebg.png" alt="PVM Large" fill className="object-contain grayscale" />
          </div>
        </div>
      </section>

      {/* Active Releases Section */}
      <section id="releases" className="py-20 px-8 bg-slate-950">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-2xl font-bold text-white mb-8 border-l-4 border-gold pl-4 uppercase tracking-wider">Active PVM Releases</h2>
          <div className="overflow-x-auto">
            <table className="pvm-table">
              <thead>
                <tr>
                  <th>Version</th>
                  <th>Status</th>
                  <th>First released</th>
                  <th>End of support</th>
                  <th>Download</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td className="font-bold text-white">0.1.0-alpha</td>
                  <td className="text-gold font-bold">alpha</td>
                  <td>2026-04-25</td>
                  <td>TBD</td>
                  <td><a href="#">GitHub Release</a></td>
                </tr>
                <tr>
                  <td className="font-bold text-white">main</td>
                  <td className="text-blue-400">development</td>
                  <td>ongoing</td>
                  <td>ongoing</td>
                  <td><a href="#">Source Code</a></td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
      </section>

      {/* Supported Python Versions Section */}
      <section className="py-20 px-8">
        <div className="max-w-6xl mx-auto">
          <h2 className="text-2xl font-bold text-white mb-8 border-l-4 border-blue-500 pl-4 uppercase tracking-wider">Supported Python Versions</h2>
          <div className="overflow-x-auto">
            <table className="pvm-table">
              <thead>
                <tr>
                  <th>Python Version</th>
                  <th>PVM Support</th>
                  <th>Install Command</th>
                </tr>
              </thead>
              <tbody>
                {[
                  { v: "Python 3.14", s: "planned", c: "pvm install 3.14" },
                  { v: "Python 3.13", s: "supported", c: "pvm install 3.13" },
                  { v: "Python 3.12", s: "supported", c: "pvm install 3.12" },
                  { v: "Python 3.11", s: "supported", c: "pvm install 3.11" },
                  { v: "Python 3.10", s: "supported", c: "pvm install 3.10" },
                ].map((row, i) => (
                  <tr key={i}>
                    <td className="font-bold text-white">{row.v}</td>
                    <td><span className={cn("px-2 py-0.5 rounded text-[10px] font-bold uppercase", row.s === "supported" ? "bg-green-500/20 text-green-400" : "bg-blue-500/20 text-blue-400")}>{row.s}</span></td>
                    <td className="font-mono text-xs">{row.c}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </div>
      </section>

      {/* Install Methods */}
      <section id="install" className="py-20 px-8 bg-white/5 border-y border-white/5">
        <div className="max-w-6xl mx-auto grid md:grid-cols-2 lg:grid-cols-4 gap-8">
          {[
            { tag: "POSIX", title: "Shell Install", desc: "One-line installation for bash/sh/zsh environments." },
            { tag: "GIT", title: "Git Checkout", desc: "Clone and manage manually for custom environments." },
            { tag: "WSL", title: "WSL1 & WSL2", desc: "Fully verified support for Linux on Windows." },
            { tag: "WIN", title: "Native Windows", desc: "Stand-alone executable (Inno Setup) coming soon." },
          ].map((item, i) => (
            <div key={i} className="p-6 border border-white/10 bg-navy-dark rounded-lg hover:border-gold/50 transition-colors group">
              <span className="text-[10px] font-black text-gold mb-2 block tracking-widest">{item.tag}</span>
              <h3 className="font-bold text-white mb-3 flex items-center justify-between">
                {item.title} <ChevronRight className="w-4 h-4 group-hover:translate-x-1 transition-transform" />
              </h3>
              <p className="text-slate-400 text-xs leading-relaxed">{item.desc}</p>
            </div>
          ))}
        </div>
      </section>

      {/* Documentation Blocks */}
      <section id="docs" className="py-20 px-8">
        <div className="max-w-6xl mx-auto grid md:grid-cols-2 lg:grid-cols-4 gap-12">
          <div className="doc-card">
            <h3>Install</h3>
            <p>Setup PVM on your system, configure PATH, and manage parallel download engines.</p>
            <a href="#">Learn more &raquo;</a>
          </div>
          <div className="doc-card">
            <h3>Commands</h3>
            <h3 className="border-none mb-1 text-[10px] opacity-50">API Reference</h3>
            <p>Full reference for ls-remote, alias, venv, and version switching flags.</p>
            <a href="#">Learn more &raquo;</a>
          </div>
          <div className="doc-card">
            <h3>.pvmrc</h3>
            <p>Project-level automation. Learn how to pin Python versions per directory via simple config files.</p>
            <a href="#">Learn more &raquo;</a>
          </div>
          <div className="doc-card">
            <h3>Troubleshoot</h3>
            <p>Resolution steps for shell integration, path priority, and aria2c fallbacks.</p>
            <a href="#">Learn more &raquo;</a>
          </div>
        </div>
      </section>

      {/* Verification Section */}
      <section className="py-20 px-8 bg-slate-950/50">
        <div className="max-w-4xl mx-auto text-center">
          <h2 className="text-2xl font-bold text-white mb-12">Verification & Diagnostics</h2>
          <div className="grid grid-cols-2 md:grid-cols-4 gap-6 text-[11px] font-mono font-bold uppercase tracking-widest">
            <div className="p-4 border border-white/5 rounded hover:bg-gold/5 transition-colors">pvm version</div>
            <div className="p-4 border border-white/5 rounded hover:bg-gold/5 transition-colors">pvm system</div>
            <div className="p-4 border border-white/5 rounded hover:bg-gold/5 transition-colors">pvm current</div>
            <div className="p-4 border border-white/5 rounded hover:bg-gold/5 transition-colors">pvm list</div>
          </div>
        </div>
      </section>

      {/* Security Section */}
      <section id="security" className="py-24 px-8 border-t border-white/5 bg-navy-dark/30">
        <div className="max-w-3xl mx-auto">
          <div className="flex items-center gap-4 mb-8">
            <Shield className="w-8 h-8 text-gold" />
            <h2 className="text-2xl font-bold text-white uppercase tracking-tight">Security & Transparency</h2>
          </div>
          <div className="space-y-6 text-slate-400 text-sm leading-relaxed">
            <div className="flex gap-4">
              <Check className="w-5 h-5 text-green-500 shrink-0" />
              <p><strong className="text-white">Official Sources:</strong> All binaries are downloaded directly from python.org FTP/HTTPS servers using verified checksums.</p>
            </div>
            <div className="flex gap-4">
              <Check className="w-5 h-5 text-green-500 shrink-0" />
              <p><strong className="text-white">Isolated Environment:</strong> PVM resides entirely in your user directory (~/.pvm). No sudo required, no system-wide contamination.</p>
            </div>
            <div className="flex gap-4">
              <Check className="w-5 h-5 text-green-500 shrink-0" />
              <p><strong className="text-white">Open Layout:</strong> Simple shell-based version switching with zero opaque binary manipulation outside the downloader.</p>
            </div>
          </div>
        </div>
      </section>

      {/* Multi-column Footer */}
      <footer className="bg-navy-dark text-white/80 py-20 border-t border-white/10">
        <div className="max-w-6xl mx-auto px-8 grid grid-cols-2 md:grid-cols-3 lg:grid-cols-5 gap-12 text-sm">
          <div className="space-y-4">
            <h4 className="font-bold text-white border-b border-white/20 pb-2">About</h4>
            <ul className="space-y-2 text-slate-400">
              <li><a href="#" className="hover:text-gold">Project Identity</a></li>
              <li><a href="#" className="hover:text-gold">Architecture</a></li>
              <li><a href="#" className="hover:text-gold">Contributors</a></li>
              <li><a href="#" className="hover:text-gold">Sponsors</a></li>
            </ul>
          </div>
          <div className="space-y-4">
            <h4 className="font-bold text-white border-b border-white/20 pb-2">Downloads</h4>
            <ul className="space-y-2 text-slate-400">
              <li><a href="#" className="hover:text-gold">Latest Release</a></li>
              <li><a href="#" className="hover:text-gold">Full List</a></li>
              <li><a href="#" className="hover:text-gold">Source Code</a></li>
              <li><a href="#" className="hover:text-gold">Windows WSL</a></li>
            </ul>
          </div>
          <div className="space-y-4">
            <h4 className="font-bold text-white border-b border-white/20 pb-2">Documentation</h4>
            <ul className="space-y-2 text-slate-400">
              <li><a href="#" className="hover:text-gold">CLI Reference</a></li>
              <li><a href="#" className="hover:text-gold">Guides</a></li>
              <li><a href="#" className="hover:text-gold">Venv Setup</a></li>
              <li><a href="#" className="hover:text-gold">Legacy Versions</a></li>
            </ul>
          </div>
          <div className="space-y-4">
            <h4 className="font-bold text-white border-b border-white/20 pb-2">Community</h4>
            <ul className="space-y-2 text-slate-400">
              <li><a href="#" className="hover:text-gold">GitHub Discussions</a></li>
              <li><a href="#" className="hover:text-gold">Issue Tracker</a></li>
              <li><a href="#" className="hover:text-gold">Twitter/X</a></li>
              <li><a href="#" className="hover:text-gold">Discord</a></li>
            </ul>
          </div>
          <div className="space-y-4">
            <h4 className="font-bold text-white border-b border-white/20 pb-2">Project</h4>
            <ul className="space-y-2 text-slate-400">
              <li><a href="#" className="hover:text-gold">MIT License</a></li>
              <li><a href="#" className="hover:text-gold">Security Policy</a></li>
              <li><a href="#" className="hover:text-gold">Code of Conduct</a></li>
              <li><a href="#" className="hover:text-gold">Contact</a></li>
            </ul>
          </div>
        </div>
        <div className="mt-16 text-center text-xs text-slate-500 border-t border-white/5 pt-12">
          <p>© 2026 PVM Shell Project Team. Python and the Python logos are trademarks or registered trademarks of the Python Software Foundation.</p>
        </div>
      </footer>
    </div>
  );
}
