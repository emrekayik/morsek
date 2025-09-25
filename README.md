# Morsek - Morse Network Protocol

[![Build and Test](https://github.com/emrekayik/morsek/actions/workflows/build.yml/badge.svg)](https://github.com/emrekayik/morsek/actions/workflows/build.yml)
[![Code Quality](https://github.com/emrekayik/morsek/actions/workflows/quality.yml/badge.svg)](https://github.com/emrekayik/morsek/actions/workflows/quality.yml)
[![Release](https://github.com/emrekayik/morsek/actions/workflows/release.yml/badge.svg)](https://github.com/emrekayik/morsek/actions/workflows/release.yml)

A high-performance Morse code network protocol implementation in Nim.

## Features

- **Efficient Bit Packing**: Optimized encoding of Morse signals into binary format
- **Network Protocol**: M-NET protocol with proper headers for network transmission
- **Cross-Platform**: Builds on Windows, Linux, and macOS
- **Fast Performance**: Written in Nim for optimal speed and memory usage

## Quick Start

### Building

```bash
# Clone the repository
git clone https://github.com/emrekayik/morsek.git
cd morsek

# Install dependencies and build
nimble build

# Run tests
nimble test
```

### Usage

```nim
import morsek/morse

# Encode text to Morse code bits
let (bits, bitLength) = encodeMorse("HELLO WORLD")
echo "Encoded bits: ", bits
echo "Total bits: ", bitLength
```

## Protocol Specification

The M-NET protocol uses the following header format:

```
| Magic (4) | Version (1) | Type (1) | Payload Length (4) | Bit Length (4) | Payload (variable) |
```

- **Magic Number**: `0x4D4F5253` ("MORS")
- **Version**: Protocol version (currently 0x01)
- **Message Type**: 0x01 for text messages
- **Payload Length**: Size of encoded payload in bytes
- **Bit Length**: Total number of bits in the Morse signal

## Morse Code Encoding

- **Dot (.)**: Single bit `1`
- **Dash (-)**: Three bits `111`
- **Element Gap**: Single bit `0` (between dots/dashes in same character)
- **Character Gap**: Three bits `000` (between characters)
- **Word Gap**: Seven bits `0000000` (between words)

## Development

### Prerequisites

- Nim 2.2.4 or later
- Nimble package manager

### Running Tests

```bash
nimble test
```

### Building Documentation

```bash
nim doc --project --index:on src/morsek.nim
```

## CI/CD

This project uses GitHub Actions for:

- **Build & Test**: Automated testing on Windows, Linux, and macOS
- **Code Quality**: Static analysis and documentation generation
- **Releases**: Automated binary releases when tags are pushed

## License

MIT License - see [LICENSE](LICENSE) for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests for new functionality
5. Ensure all tests pass
6. Submit a pull request

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and changes.
