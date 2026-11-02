import 'dart:math' as math;
import 'dart:typed_data';

/// Circular sample buffer capable of capturing snapshots and serializing them into standard WAV files.
class WaveWriter {
  WaveWriter({int bufferSize = 44100 * 5}) {
    setBufferSize(bufferSize);
  }

  Float32List? _buffer;
  int _insertPosition = 0;
  int _numValues = 0;
  Float32List? _snapshot;

  /// Current buffer capacity in number of samples.
  int get bufferSize => _buffer?.length ?? 0;

  /// Number of valid samples currently recorded in the circular buffer.
  int get numValues => _numValues;

  /// The most recent stored snapshot, or null if none taken.
  Float32List? get snapshot => _snapshot;

  /// Configures circular buffer capacity to [size] samples.
  void setBufferSize(int size) {
    if (size <= 0) {
      _buffer = null;
      _numValues = 0;
      _insertPosition = 0;
      return;
    }
    if (_buffer?.length != size) {
      _buffer = Float32List(size);
      _numValues = 0;
      _insertPosition = 0;
    }
  }

  /// Appends [input] float samples to the circular buffer.
  void appendData(Float32List input, [int? count]) {
    final buf = _buffer;
    if (buf == null || buf.isEmpty) return;

    final numInput = count ?? input.length;
    final maxSize = buf.length;
    var inputIndex = 0;

    while (inputIndex < numInput) {
      final bufIndex = _insertPosition % maxSize;
      final numCopy = math.min(maxSize - bufIndex, numInput - inputIndex);
      for (var i = 0; i < numCopy; i++) {
        buf[bufIndex + i] = input[inputIndex + i];
      }
      inputIndex += numCopy;
      _insertPosition += numCopy;
      _numValues += numCopy;
    }
    _numValues = math.min(_numValues, maxSize);
  }

  /// Freezes a snapshot of the current circular buffer in linear chronological order.
  void storeSnapshot() {
    final buf = _buffer;
    if (buf == null || _numValues == 0) {
      _snapshot = Float32List(0);
      return;
    }

    final maxSize = buf.length;
    final linear = Float32List(_numValues);
    final bufStart = (_insertPosition - _numValues) % maxSize;
    final firstPart = math.min(_numValues, maxSize - bufStart);

    for (var i = 0; i < firstPart; i++) {
      linear[i] = buf[bufStart + i];
    }
    final secondPart = _numValues - firstPart;
    for (var i = 0; i < secondPart; i++) {
      linear[firstPart + i] = buf[i];
    }
    _snapshot = linear;
  }

  /// Encodes the current snapshot as a standard 32-bit IEEE float WAV file.
  Uint8List? encodeSnapshotWav({required int sampleRate}) {
    final snap = _snapshot;
    if (snap == null || snap.isEmpty) return null;
    return encodeWavBytes(data: snap, sampleRate: sampleRate);
  }

  /// Serializes [data] float samples into a compliant IEEE 754 32-bit float mono WAV binary.
  static Uint8List encodeWavBytes({
    required Float32List data,
    required int sampleRate,
    int numChannels = 1,
  }) {
    const bitsPerSample = 32;
    final byteRate = sampleRate * numChannels * (bitsPerSample ~/ 8);
    final blockAlign = numChannels * (bitsPerSample ~/ 8);
    final dataSize = data.length * (bitsPerSample ~/ 8);

    // Total file size: 58 bytes header + dataSize
    final totalSize = 58 + dataSize;
    final bytes = Uint8List(totalSize);
    final byteData = ByteData.sublistView(bytes);

    // RIFF chunk descriptor
    bytes[0] = 0x52; // 'R'
    bytes[1] = 0x49; // 'I'
    bytes[2] = 0x46; // 'F'
    bytes[3] = 0x46; // 'F'
    byteData.setUint32(4, dataSize + 50, Endian.little); // chunk size

    // WAVE format
    bytes[8] = 0x57; // 'W'
    bytes[9] = 0x41; // 'A'
    bytes[10] = 0x56; // 'V'
    bytes[11] = 0x45; // 'E'

    // fmt subchunk
    bytes[12] = 0x66; // 'f'
    bytes[13] = 0x6D; // 'm'
    bytes[14] = 0x74; // 't'
    bytes[15] = 0x20; // ' '
    byteData.setUint32(16, 18, Endian.little); // subchunk size = 18 for float
    byteData.setUint16(20, 3, Endian.little); // audio format 3 = IEEE FLOAT
    byteData.setUint16(22, numChannels, Endian.little);
    byteData.setUint32(24, sampleRate, Endian.little);
    byteData.setUint32(28, byteRate, Endian.little);
    byteData.setUint16(32, blockAlign, Endian.little);
    byteData.setUint16(34, bitsPerSample, Endian.little);
    byteData.setUint16(36, 0, Endian.little); // cbSize = 0

    // fact subchunk (required for non-PCM formats)
    bytes[38] = 0x66; // 'f'
    bytes[39] = 0x61; // 'a'
    bytes[40] = 0x63; // 'c'
    bytes[41] = 0x74; // 't'
    byteData.setUint32(42, 4, Endian.little);
    byteData.setUint32(46, data.length, Endian.little); // sample count

    // data subchunk
    bytes[50] = 0x64; // 'd'
    bytes[51] = 0x61; // 'a'
    bytes[52] = 0x74; // 't'
    bytes[53] = 0x61; // 'a'
    byteData.setUint32(54, dataSize, Endian.little);

    // Float32 sample data in little endian
    var offset = 58;
    for (var i = 0; i < data.length; i++) {
      byteData.setFloat32(offset, data[i], Endian.little);
      offset += 4;
    }

    return bytes;
  }
}
