# Homebrew formula for Alloy CLI
# Auto-updated by release workflow — do not edit manually

class Alloy < Formula
  desc "Polyglot FaaS platform for orchestrating C++, Python, and Rust DAGs"
  homepage "https://github.com/alloy-works/alloy"
  version "0.1.0-alpha.1"

  on_macos do
    url "https://github.com/alloy-works/homebrew-tap/releases/download/v0.1.0-alpha.1/alloy-v0.1.0-alpha.1-aarch64-apple-darwin.tar.gz"
    sha256 "f208cef31391b24f6186e5fc69e322fa187f0137405c6fd378b084236a4aa8fe"
  end

  on_linux do
    on_arm do
      url "https://github.com/alloy-works/homebrew-tap/releases/download/v0.1.0-alpha.1/alloy-v0.1.0-alpha.1-aarch64-unknown-linux-gnu.tar.gz"
      sha256 "3e1f7009e3bb1c54f9211056ea9a93919f35614d80d5fd4330bd5d2151a2378a"
    end
    on_intel do
      url "https://github.com/alloy-works/homebrew-tap/releases/download/v0.1.0-alpha.1/alloy-v0.1.0-alpha.1-x86_64-unknown-linux-gnu.tar.gz"
      sha256 "b6869914f5e3901824f5c64b31854f2ddc3217d05a75303b83fdfdc374afba24"
    end
  end

  def install
    bin.install "alloy"

    # Service wrapper: pulls image if missing, cleans stale containers, runs in foreground
    (libexec/"alloy-service").write <<~SH
      #!/bin/bash
      set -e

      # launchd runs with a minimal PATH — add common Docker locations
      export PATH="/usr/local/bin:/opt/homebrew/bin:\$PATH"

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
