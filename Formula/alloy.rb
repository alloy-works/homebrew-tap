# Homebrew formula for Alloy CLI
# Auto-updated by release workflow — do not edit manually

class Alloy < Formula
  desc "Polyglot FaaS platform for orchestrating C++, Python, and Rust DAGs"
  homepage "https://github.com/alloy-works/alloy"
  version "0.1.0-alpha.1"

  on_macos do
    url "https://github.com/alloy-works/homebrew-tap/releases/download/v0.1.0-alpha.1/alloy-v0.1.0-alpha.1-aarch64-apple-darwin.tar.gz"
    sha256 "a2645fead81de555c343312f65292624621e96472249576781322407348520b0"
  end

  on_linux do
    on_arm do
      url "https://github.com/alloy-works/homebrew-tap/releases/download/v0.1.0-alpha.1/alloy-v0.1.0-alpha.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "f26880ffe7f45529a241a780fe682aa9ac8d748064bfa8dc24b0ccb535ccd6d5"
    end
    on_intel do
      url "https://github.com/alloy-works/homebrew-tap/releases/download/v0.1.0-alpha.1/alloy-v0.1.0-alpha.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "90698a8b05144a9f1aa723073d6a71173403e6d7bd8178ee0b66b7785a95692e"
    end
  end

  def install
    bin.install "alloy"

    # Service wrapper: pulls image if missing, cleans stale containers, runs in foreground
    (libexec/"alloy-service").write <<~SH
      #!/bin/bash
      set -e
      IMAGE="ghcr.io/alloy-works/alloy:dev"
      CONTAINER="alloy-dev"

      if ! command -v docker >/dev/null 2>&1; then
        echo "Error: Docker is required. Install Docker Desktop first."
        exit 1
      fi

      if ! docker image inspect "\$IMAGE" >/dev/null 2>&1; then
        echo "Pulling \$IMAGE..."
        if ! docker pull "\$IMAGE"; then
          echo "Error: Could not pull \$IMAGE"
          echo "Run 'docker login ghcr.io' with a PAT that has read:packages scope"
          exit 1
        fi
      fi

      docker rm -f "\$CONTAINER" 2>/dev/null || true

      exec docker run --rm \\
        -p 50052:50052 \\
        --shm-size=4g \\
        --name "\$CONTAINER" \\
        "\$IMAGE"
    SH
    chmod 0755, libexec/"alloy-service"
  end

  service do
    run [opt_libexec/"alloy-service"]
    keep_alive true
    log_path var/"log/alloy.log"
    error_log_path var/"log/alloy.log"
  end

  def caveats
    <<~EOS
      The Alloy CLI is installed.

      First-time setup (requires GHCR access):
        docker login ghcr.io

      Then start the backend:
        brew services start alloy

      The CLI connects to localhost:50052 by default.
    EOS
  end

  test do
    assert_match "Alloy orchestration platform", shell_output("#{bin}/alloy --help")
  end
end
