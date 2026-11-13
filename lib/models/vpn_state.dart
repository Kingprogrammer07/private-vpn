enum VpnConnectionState {
  disconnected,
  connecting,
  connected,
  disconnecting,
  error,
}

class VpnStatusInfo {
  final VpnConnectionState state;
  final int uploadSpeedBytes; // bytes per second
  final int downloadSpeedBytes; // bytes per second
  final int totalUploadBytes;
  final int totalDownloadBytes;
  final Duration connectedDuration;
  final int pingMs;

  const VpnStatusInfo({
    this.state = VpnConnectionState.disconnected,
    this.uploadSpeedBytes = 0,
    this.downloadSpeedBytes = 0,
    this.totalUploadBytes = 0,
    this.totalDownloadBytes = 0,
    this.connectedDuration = Duration.zero,
    this.pingMs = -1,
  });

  VpnStatusInfo copyWith({
    VpnConnectionState? state,
    int? uploadSpeedBytes,
    int? downloadSpeedBytes,
    int? totalUploadBytes,
    int? totalDownloadBytes,
    Duration? connectedDuration,
    int? pingMs,
  }) {
    return VpnStatusInfo(
      state: state ?? this.state,
      uploadSpeedBytes: uploadSpeedBytes ?? this.uploadSpeedBytes,
      downloadSpeedBytes: downloadSpeedBytes ?? this.downloadSpeedBytes,
      totalUploadBytes: totalUploadBytes ?? this.totalUploadBytes,
      totalDownloadBytes: totalDownloadBytes ?? this.totalDownloadBytes,
      connectedDuration: connectedDuration ?? this.connectedDuration,
      pingMs: pingMs ?? this.pingMs,
    );
  }

  static String formatSpeed(int bytesPerSecond) {
    if (bytesPerSecond < 1024) {
      return '$bytesPerSecond B/s';
    } else if (bytesPerSecond < 1024 * 1024) {
      return '${(bytesPerSecond / 1024).toStringAsFixed(1)} KB/s';
    } else {
      return '${(bytesPerSecond / (1024 * 1024)).toStringAsFixed(2)} MB/s';
    }
  }

  static String formatBytes(int totalBytes) {
    if (totalBytes < 1024) {
      return '$totalBytes B';
    } else if (totalBytes < 1024 * 1024) {
      return '${(totalBytes / 1024).toStringAsFixed(1)} KB';
    } else if (totalBytes < 1024 * 1024 * 1024) {
      return '${(totalBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    } else {
      return '${(totalBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

  static String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(d.inHours);
    final minutes = twoDigits(d.inMinutes.remainder(60));
    final seconds = twoDigits(d.inSeconds.remainder(60));
    return d.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}
