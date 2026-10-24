/// Smaller images for lists, to spare scarce mobile data.
///
/// A Cloudinary URL gets a delivery transformation (fit inside [width] px,
/// automatic quality and format), so a list card downloads tens of KB
/// instead of a full-size design. Other URLs, and Cloudinary URLs that
/// already carry a transformation, are returned unchanged.
class ImageSizing {
  ImageSizing._();

  static String thumb(String url, {int width = 480}) {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.host.endsWith('res.cloudinary.com')) return url;
    final i = uri.pathSegments.indexOf('upload');
    if (i < 0 || i + 1 >= uri.pathSegments.length) return url;
    final next = uri.pathSegments[i + 1];
    // Already transformed (e.g. "w_400,q_auto" or "c_fill,..."); leave it.
    if (RegExp(r'^[a-z]{1,3}_[^/]+').hasMatch(next) && !RegExp(r'^v\d+$').hasMatch(next)) return url;
    final segments = [
      ...uri.pathSegments.take(i + 1),
      'c_limit,w_$width,q_auto,f_auto',
      ...uri.pathSegments.skip(i + 1),
    ];
    return uri.replace(pathSegments: segments).toString();
  }
}
