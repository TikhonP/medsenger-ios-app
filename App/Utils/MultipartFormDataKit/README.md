MultipartFormDataKit
====================

Source: https://github.com/Kuniwak/MultipartFormDataKit/blob/master/LICENSE

![Swift 4 compatible](https://img.shields.io/badge/Swift%20version-4-green.svg)
![Swift Package Manager and Carthage and CocoaPods compatible](https://img.shields.io/badge/SPM%20%7C%20Carthage%20%7C%20CocoaPods-compatible-green.svg)
[![v1.0.1](https://img.shields.io/badge/version-1.0.1-blue.svg)](https://github.com/Kuniwak/MultipartFormData/releases)
[![Build Status](https://www.bitrise.io/app/8c05b2758bfbf0d8/status.svg?token=vqY7qlmU6qeCPZ17EX7vRA&branch=master)](https://www.bitrise.io/app/8c05b2758bfbf0d8)


`multipart/form-data` for Swift.


Basic Usage
-----------

```swift
let multipartFormData = try MultipartFormData.Builder.build(
    with: [
        (
            name: "example1",
            filename: nil,
            mimeType: nil,
            data: "Hello, World!".data(using: .utf8)!
        ),
        (
            name: "example2",
            filename: "example.txt",
            mimeType: MIMEType.textPlain,
            data: "EXAMPLE_TXT".data(using: .utf8)!
        ),
    ],
    willSeparateBy: RandomBoundaryGenerator.generate()
)

var request = URLRequest(url: URL(string: "http://example.com")!)
request.httpMethod = "POST"
request.setValue(multipartFormData.contentType, forHTTPHeaderField: "Content-Type")
request.httpBody = multipartFormData.body

let task = URLSession.shared.dataTask(with: request)
task.resume()
```



Advanced Usage
--------------

```swift
let multipartFormData = MultipartFormData(
    uniqueAndValidLengthBoundary: "boundary",
    body: [
        MultipartFormData.Part(
            contentDisposition: ContentDisposition(
                name: Name(asPercentEncoded: "field%201"),
                filename: nil
            ),
            contentType: nil,
            content: "value1".data(using: .utf8)!
        ),
        MultipartFormData.Part(
            contentDisposition: ContentDisposition(
                name: Name(asPercentEncoded: "field%202"),
                filename: Filename(asPercentEncoded: "example.txt")
            ),
            contentType: ContentType(representing: .textPlain),
            content: "value2".data(using: .utf8)!
        ),
    ]
)

print(multipartFormData.header.name)
// Content-Type

print(multipartFormData.header.value)
// multipart/form-data; boundary="boundary"

switch multipartFormData.asData() {
case let .valid(data):
    print(String(data: data, encoding: .utf8))

    // --boundary
    // Content-Disposition: form-data; name="field1"
    // 
    // value1
    // --boundary
    // Content-Disposition: form-data; name="filed2"; filename="example.txt"
    // Content-Type: text/plain
    // 
    // value2
    // --boundary--

case let .invalid(error):
    print(error)
}
```


License
-------

Copyright (c) 2017 Kuniwak <orga.chem.job+multipart-form-data@gmail.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
