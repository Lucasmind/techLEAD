# Contributing to Tech LEAD

We love your input! We want to make contributing to Tech LEAD as easy and transparent as possible, whether it's:

- Reporting a bug
- Discussing the current state of the code
- Submitting a fix
- Proposing new features
- Becoming a maintainer

## Development Process

We use GitHub to host code, to track issues and feature requests, as well as accept pull requests.

1. Fork the repo and create your branch from `main`
2. If you've added code that should be tested, add tests
3. If you've changed APIs, update the documentation
4. Ensure the test suite passes
5. Make sure your code follows the existing style
6. Issue that pull request!

## Pull Request Process

1. Update the README.md with details of changes to the interface
2. Update the CLAUDE.md if you've changed AI prompts or workflows
3. The PR will be merged once you have the sign-off of at least one maintainer

## Any contributions you make will be under the MIT Software License

When you submit code changes, your submissions are understood to be under the same [MIT License](LICENSE) that covers the project.

## Report bugs using GitHub's [issue tracker](https://github.com/Lucasmind/techLEAD/issues)

We use GitHub issues to track public bugs. Report a bug by [opening a new issue](https://github.com/Lucasmind/techLEAD/issues/new).

**Great Bug Reports** tend to have:

- A quick summary and/or background
- Steps to reproduce
  - Be specific!
  - Give sample code if you can
- What you expected would happen
- What actually happens
- Notes (possibly including why you think this might be happening, or stuff you tried that didn't work)

## Code Style

### n8n Workflows
- Use descriptive node names
- Add comments for complex logic
- Export workflows as JSON with proper formatting

### Documentation
- Use clear, concise language
- Include code examples where appropriate
- Keep README and CLAUDE.md up to date

### Scripts
- Add error handling
- Include helpful output messages
- Make scripts idempotent where possible

## Testing

Before submitting a PR:

1. Test all n8n workflows with sample data
2. Verify Claude CLI integration works
3. Test Telegram bot commands
4. Check Docker services start correctly
5. Ensure documentation is accurate

## License

By contributing, you agree that your contributions will be licensed under its MIT License.

## References

This document was adapted from the open-source contribution guidelines for [Facebook's Draft](https://github.com/facebook/draft-js/blob/a9316a723f9e918afde44dea68b5f9f39b7d9b00/CONTRIBUTING.md)