meson_setup_args := if os_family() == "windows" { "--backend=vs" } else { "" }

run: build
    cd Redist; ../build/U7Revisited

build: setup
    meson compile -C build

setup:
    meson setup --buildtype=release {{ meson_setup_args }} build

run-debug: build-debug
    cd Redist; ../build-dbg/U7Revisited

build-debug: setup-debug
    meson compile -C build-dbg

setup-debug:
    meson setup {{ meson_setup_args }} build-dbg
