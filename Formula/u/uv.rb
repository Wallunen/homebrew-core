class Uv < Formula
  desc "Extremely fast Python package installer and resolver, written in Rust"
  homepage "https://github.com/astral-sh/uv"
  url "https://github.com/astral-sh/uv/archive/refs/tags/0.3.5.tar.gz"
  sha256 "a5c86337496727ae7c86d2396306717212ffb66e6cf382cad9e7d67ef4f5b6a1"
  license any_of: ["Apache-2.0", "MIT"]
  head "https://github.com/astral-sh/uv.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "99f2228cc59bdcfe626dd754075dc5e7001cb67096fb950d50e26a5103a5d860"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "b668dd5287b6ce89bc87eb6cf43a48223b3169c93781f5080a6998ba94416e90"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "99f9dcf4058e15300086f0ded4cc436ddc3ad128c9df9a1864a7d749b99a08fe"
    sha256 cellar: :any_skip_relocation, sonoma:         "92be3e9088dc3885a40796752804748a09671086a74cae081aafec0429cfdc75"
    sha256 cellar: :any_skip_relocation, ventura:        "8c82be98dc5b4897a22a740b45e71720b3a2a5abdf85105850144b131422afc0"
    sha256 cellar: :any_skip_relocation, monterey:       "f61c84067219d5efab12306631e6e9e15e4352e5c92552f10d97ab392bbe703f"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "98872701d0ba8f3dc23ce3c53b0dc1a73641f3d1395b9c294b939b4144cc8f2c"
  end

  depends_on "pkg-config" => :build
  depends_on "rust" => :build

  uses_from_macos "python" => :test
  uses_from_macos "xz"

  on_linux do
    # On macOS, bzip2-sys will use the bundled lib as it cannot find the system or brew lib.
    # We only ship bzip2.pc on Linux which bzip2-sys needs to find library.
    depends_on "bzip2"
  end

  def install
    ENV["UV_COMMIT_HASH"] = ENV["UV_COMMIT_SHORT_HASH"] = tap.user
    ENV["UV_COMMIT_DATE"] = time.strftime("%F")
    system "cargo", "install", "--no-default-features", *std_cargo_args(path: "crates/uv")
    generate_completions_from_executable(bin/"uv", "generate-shell-completion")
  end

  test do
    (testpath/"requirements.in").write <<~EOS
      requests
    EOS

    compiled = shell_output("#{bin}/uv pip compile -q requirements.in")
    assert_match "This file was autogenerated by uv", compiled
    assert_match "# via requests", compiled

    assert_match "ruff 0.5.1", shell_output("#{bin}/uvx -q ruff@0.5.1 --version")
  end
end
