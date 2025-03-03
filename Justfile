# Check project sources for style problems.
lint:
    find Source/ -name '*.cpp' -o -name '*.h' | xargs cpplint

# Format all project source code with ClangFormat.
format-sources:
    find Source/ -name '*.cpp' -o -name '*.h' | xargs clang-format -i --verbose
