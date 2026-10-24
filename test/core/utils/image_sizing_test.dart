import 'package:flutter_test/flutter_test.dart';
import 'package:maktoob/core/utils/image_sizing.dart';

void main() {
  test('a Cloudinary image is fitted, compressed and auto-formatted for lists', () {
    expect(
      ImageSizing.thumb('https://res.cloudinary.com/maktoob/image/upload/v1712/designs/abc.png'),
      'https://res.cloudinary.com/maktoob/image/upload/c_limit,w_480,q_auto,f_auto/v1712/designs/abc.png',
    );
    expect(
      ImageSizing.thumb('https://res.cloudinary.com/m/image/upload/abc.jpg', width: 300),
      'https://res.cloudinary.com/m/image/upload/c_limit,w_300,q_auto,f_auto/abc.jpg',
    );
  });

  test('other URLs and already-transformed ones are left alone', () {
    const own = 'https://maktoob.social/storage/events/cover.jpg';
    const done = 'https://res.cloudinary.com/m/image/upload/w_200,q_auto/v1/abc.png';
    expect(ImageSizing.thumb(own), own);
    expect(ImageSizing.thumb(done), done);
    expect(ImageSizing.thumb('not a url'), 'not a url');
  });
}
