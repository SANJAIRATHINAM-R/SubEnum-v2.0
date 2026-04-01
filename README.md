# 🕵️‍♂️ SubEnum v2.0

### ⚡ Professional Bash-Based Subdomain Enumeration Framework

<p align="center">

<img src="https://img.shields.io/badge/Bash-Tool-4EAA25?style=for-the-badge&logo=gnu-bash&logoColor=white">
<img src="https://img.shields.io/badge/Platform-Kali%20Linux-268BEE?style=for-the-badge&logo=linux&logoColor=white">
<img src="https://img.shields.io/github/stars/SANJAIRATHINAM-R/SubEnum-v2.0?style=for-the-badge">
<img src="https://img.shields.io/github/forks/SANJAIRATHINAM-R/SubEnum-v2.0?style=for-the-badge">
<img src="https://img.shields.io/github/issues/SANJAIRATHINAM-R/SubEnum-v2.0?style=for-the-badge">
<img src="https://img.shields.io/github/license/SANJAIRATHINAM-R/SubEnum-v2.0?style=for-the-badge">
<img src="https://img.shields.io/badge/Status-Active-success?style=for-the-badge">
<img src="https://img.shields.io/badge/Bug%20Bounty-Ready-orange?style=for-the-badge">

</p>

---

## 🚀 Overview

**SubEnum v2.0** is a high-performance Bash-based subdomain enumeration tool built for modern reconnaissance workflows.

It combines speed, accuracy, and clean CLI design to deliver a **Kali Linux–style experience** for cybersecurity professionals and bug bounty hunters.

---

## 🎯 Features

* ⚡ Parallel scanning using `xargs -P`
* 🔍 Dual DNS resolution (`dig` + `host`)
* 🌐 HTTP/HTTPS validation (`curl`)
* 📊 Real-time progress bar (speed, ETA)
* 🎨 Colored CLI output (Kali-style)
* 📁 Output & logging support
* 🧹 Auto cleanup with signal handling
* 🔐 Stable & efficient execution

---

## 🖼️ Screenshots

### 🔥 Tool Output

![Output](https://via.placeholder.com/900x400?text=SubEnum+Output)

### 📊 Progress Bar

![Progress](https://via.placeholder.com/900x200?text=Live+Progress+Bar)

---

## 📦 Installation

```bash
git clone https://github.com/SANJAIRATHINAM-R/SubEnum-v2.0.git
cd SubEnum-v2.0
chmod +x subenum.sh
```

---

## ▶️ Usage

```bash
./subenum.sh -d example.com -w wordlists/default.txt
```

---

## ⚙️ Options

| Flag | Description   |
| ---- | ------------- |
| -d   | Target domain |
| -w   | Wordlist      |
| -o   | Output file   |
| -t   | Threads       |
| -T   | Timeout       |
| -r   | Custom DNS    |
| -l   | Log file      |
| -x   | HTTP check    |
| -s   | Silent mode   |
| -v   | Verbose       |
| -h   | Help          |

---

## 🔥 Example

```bash
./subenum.sh -d hackerone.com -w wordlists/default.txt -t 50 -x -o results.txt
```

---

## 📂 Wordlists

Install advanced wordlists:

```bash
sudo apt install seclists
```

Example:

```
/usr/share/seclists/Discovery/DNS/subdomains-top1million-5000.txt
```

---

## ⚠️ Disclaimer

This tool is intended for:

✔ Authorized penetration testing
✔ Security research
✔ Educational purposes

❌ Unauthorized usage is strictly prohibited

---

# 👨‍💻 Author Profile

## 🔥 SANJAIRATHINAM

Cybersecurity Researcher • Ethical Hacker • CTF Platform Developer

---

## 🏢 Founder — DragonByte

Building platforms that help people learn hacking through real-world challenges.

---

## 💼 What I Do

* 🔐 Web Security
* ⚔️ Penetration Testing
* 🧠 AI Security (Prompt Injection Defense)
* 🎯 CTF Challenge Development
* 🛠️ Security Tool Development

---

## 🚀 Projects

* 🧠 PromptShield – AI security tool
* 🛡️ LLM Prompt Injection Auditor
* 🎮 DragonByte CTF Platform
* ⚡ SubEnum

---

## 🏆 Achievements

* Built real-world cybersecurity tools
* Created practical CTF challenges
* Active in cybersecurity community

---

## 🎯 Goal

To become a top cybersecurity expert and build advanced platforms that help others learn ethical hacking.

---

## 🌐 Connect With Me

* GitHub: https://github.com/SANJAIRATHINAM-R
* LinkedIn: https://linkedin.com/in/sanjairathinamn17
* Instagram: https://instagram.com/sanjairathinam

---

## ⭐ Support

If you like this project:

👉 Star ⭐ the repository
👉 Share with others
👉 Contribute ideas

---

## 🧠 Vision

> “I don’t just find vulnerabilities — I build systems that make others capable of finding them.”

---

## 📜 License

MIT License © 2026 SANJAIRATHINAM

---

<p align="center">
🔥 Built for Hackers • By a Hacker 🔥
</p>
