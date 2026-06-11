class TrafficStats {
  const TrafficStats({
    this.downloadSpeed = '0 B/s',
    this.uploadSpeed = '0 B/s',
    this.totalDownload = '0 B',
    this.totalUpload = '0 B',
    this.duration = '00:00:00',
  });

  final String downloadSpeed;
  final String uploadSpeed;
  final String totalDownload;
  final String totalUpload;
  final String duration;

  factory TrafficStats.fromWireGuard(Map<String, dynamic> data) {
    return TrafficStats(
      downloadSpeed: _formatSpeed(data['downloadSpeed']),
      uploadSpeed: _formatSpeed(data['uploadSpeed']),
      totalDownload: _formatBytes(data['totalDownload']),
      totalUpload: _formatBytes(data['totalUpload']),
      duration: data['duration']?.toString() ?? '00:00:00',
    );
  }

  static String _formatSpeed(Object? value) => '${_formatBytes(value)}/s';

  static String _formatBytes(Object? value) {
    final bytes = double.tryParse(value?.toString() ?? '') ?? 0;

    if (bytes < 1024) {
      return '${bytes.toStringAsFixed(0)} B';
    }
    if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    }
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }

    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }
}
