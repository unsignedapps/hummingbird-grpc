/*
 * Copyright 2024, gRPC Authors All rights reserved.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

//-----------------------------------------------------------------------------
// THIS FILE WAS GENERATED WITH make-sample-certs.py
//
// DO NOT UPDATE MANUALLY
//-----------------------------------------------------------------------------

#if canImport(NIOSSL)
import struct Foundation.Date
import NIOSSL

/// Wraps `NIOSSLCertificate` to provide the certificate common name and expiry date.
public struct SampleCertificate {
  public var certificate: NIOSSLCertificate
  public var commonName: String
  public var notAfter: Date

  public static let ca = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(caCert.utf8), format: .pem),
    commonName: "some-ca",
    notAfter: Date(timeIntervalSince1970: 1752992508)
  )

  public static let otherCA = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(otherCACert.utf8), format: .pem),
    commonName: "some-other-ca",
    notAfter: Date(timeIntervalSince1970: 1752992508)
  )

  public static let server = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(serverCert.utf8), format: .pem),
    commonName: "localhost",
    notAfter: Date(timeIntervalSince1970: 1752992508)
  )

  public static let exampleServer = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(exampleServerCert.utf8), format: .pem),
    commonName: "example.com",
    notAfter: Date(timeIntervalSince1970: 1752992508)
  )

  public static let serverSignedByOtherCA = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(serverSignedByOtherCACert.utf8), format: .pem),
    commonName: "localhost",
    notAfter: Date(timeIntervalSince1970: 1752992508)
  )

  public static let client = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(clientCert.utf8), format: .pem),
    commonName: "localhost",
    notAfter: Date(timeIntervalSince1970: 1752992508)
  )

  public static let clientSignedByOtherCA = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(clientSignedByOtherCACert.utf8), format: .pem),
    commonName: "localhost",
    notAfter: Date(timeIntervalSince1970: 1752992508)
  )

  public static let exampleServerWithExplicitCurve = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(serverExplicitCurveCert.utf8), format: .pem),
    commonName: "localhost",
    notAfter: Date(timeIntervalSince1970: 1752992508)
  )
}

extension SampleCertificate {
  /// Returns whether the certificate has expired.
  public var isExpired: Bool {
    return self.notAfter < Date()
  }
}

/// Provides convenience methods to make `NIOSSLPrivateKey`s for corresponding `GRPCSwiftCertificate`s.
public struct SamplePrivateKey {
  private init() {}

  public static let server = try! NIOSSLPrivateKey(bytes: .init(serverKey.utf8), format: .pem)
  public static let exampleServer = try! NIOSSLPrivateKey(
    bytes: .init(exampleServerKey.utf8),
    format: .pem
  )
  public static let client = try! NIOSSLPrivateKey(bytes: .init(clientKey.utf8), format: .pem)
  public static let exampleServerWithExplicitCurve = try! NIOSSLPrivateKey(
    bytes: .init(serverExplicitCurveKey.utf8),
    format: .pem
  )
}

// MARK: - Certificates and private keys

private let caCert = """
-----BEGIN CERTIFICATE-----
MIIDBTCCAe2gAwIBAgIUE1XhwG1p6td6PtZskTnZYjQ0DkkwDQYJKoZIhvcNAQEL
BQAwEjEQMA4GA1UEAwwHc29tZS1jYTAeFw0yNDA3MjAwNjIxNDhaFw0yNTA3MjAw
NjIxNDhaMBIxEDAOBgNVBAMMB3NvbWUtY2EwggEiMA0GCSqGSIb3DQEBAQUAA4IB
DwAwggEKAoIBAQCIgtl7zQcSBlvbhOY+ZRo0iMCs2Dx9H5OD6891QOgL8h2ajtsF
c37EUbDNTqU+V1Hzt6MnIxaEy9zHAHtHCLFIRvzlFC5eeLwLAzetfRef6VX2rBfZ
FdQe4hp/gQMbHGfxafzLtHpklxVqv9rc7YJqWk3zEMUEpv/p011oB7oKyri5zOlB
dsXuWJFbojmLDeA8JpkR2aw5R6OtcJHMEQSJ99bQam6RYwjEPntobvgsy/UiWkHi
BtfgNomuPoiDwwnSjFABgfQscooIAKO2elForaZyhHLN0RRo26L35nLod6bx+fgP
wnfc/ryNIbpZT23yOpM4xgzV5ODRD0EJQqo/AgMBAAGjUzBRMB0GA1UdDgQWBBS7
DtcKKCDw/Jy87h7R5aEnXeUMrDAfBgNVHSMEGDAWgBS7DtcKKCDw/Jy87h7R5aEn
XeUMrDAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQASjdxCIwq9
mTs6TlKF/qvWOoEffFHyyJXXmIS5GO6eDdWQV2L62SKZ7G+PFMEH9upRlhZZgpw0
xCab55a/t7CEQ+zIxHBJzICnXx3CCnPWtTLN+pbduZhQbkBOdtXZyrKjcaVWRy6O
m7719m6v5nR3m/G06VcPEoJaySu98b3zO8St1Q0QCTIKnOnfEoxkm+ADS7xhxmuA
nRt2HqcWTH7jh8Y7PyalyalMppGAyvzOLuyAUWlcS2Uu7HTYo1NgsK60etzqP+pw
hPvxLjkHf5snPkyzejrltjljbJDQUFENC1zcHBDVmn2QrNwVNGyzqHtnwUGZryEN
0PzuDoAuELcN
-----END CERTIFICATE-----
"""

private let otherCACert = """
-----BEGIN CERTIFICATE-----
MIIDETCCAfmgAwIBAgIUHMpMfaXJAkSFODWNLAj1aYwu6QAwDQYJKoZIhvcNAQEL
BQAwGDEWMBQGA1UEAwwNc29tZS1vdGhlci1jYTAeFw0yNDA3MjAwNjIxNDhaFw0y
NTA3MjAwNjIxNDhaMBgxFjAUBgNVBAMMDXNvbWUtb3RoZXItY2EwggEiMA0GCSqG
SIb3DQEBAQUAA4IBDwAwggEKAoIBAQC5JpUdD6zV340LxbVeeMve3un2lW7ydJg4
WIYK48wjnrdSkQxP69gTnE7x3V59MyvEbjyeFnGWp3g8UDfET2JlNLMgZsSvqHcX
XBk22RD+V+xyX2YJy1xjeGSnWe8BjfPX4WYGOQN8CzVfLpsdUO3UUjzbN3YjYsGO
Z9MTkK1l/09+XHRSEUV9w84kpCX1+OACdd/0LXVaxF7G8ot+9i3fVIk/ftuOqD3a
x6huwHQcio15JiHvC2V4WzU4RXNIz4wZLZCdI5Ti7lVdlO8Rv5CW4RhbUVtSFQiB
pBHbBadKEj59nLBLIWuDn0U1JpvHP95JqUgu2p52VCwr3RO66C9PAgMBAAGjUzBR
MB0GA1UdDgQWBBQ1BC7u2rBWDOGmhLmXxzyNWxwxqDAfBgNVHSMEGDAWgBQ1BC7u
2rBWDOGmhLmXxzyNWxwxqDAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUA
A4IBAQBesCR2MNnk8zi0kSRWIbmB60+eUTnY22lzh3g5O1+NfZFp7Dhlo2jZ2Zl9
TkltxKEL4sBZUgpkmW7yxs6lS1KT7m797+rf6XN07YJnW5NS804FUM/n5FrjxGq/
8dZVPxjoRQ+uGUsaVbNrLmdCuKr8TYEUvuEsroGO83u/3Ub0tgxuufFxNaLID2mG
TGjrzhkjRh9ilFT+yh5l2XeyoeYBtKifRsklZyhSjYDCWE03I5DpB/hbF5/Oy/hF
wF5nqXGRKrzbtiCIKVSppC5+Xo1B50hKXOqNdXYnXMXtf0jSUT+Gfe9Q+7VM5fCS
TvnoWDRZDdkQsYgRA6lPDL1T6AgH
-----END CERTIFICATE-----
"""

private let serverCert = """
-----BEGIN CERTIFICATE-----
MIIC4zCCAcugAwIBAgIBATANBgkqhkiG9w0BAQsFADASMRAwDgYDVQQDDAdzb21l
LWNhMB4XDTI0MDcyMDA2MjE0OFoXDTI1MDcyMDA2MjE0OFowFDESMBAGA1UEAwwJ
bG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA0/1V9rwz
2eRFNwdsaVZXH6Wm0Vt8lPu7bPwO96Z4LNjbcOjPGDx2dRkMUXvnYwd1B+dQ3dq+
5tNhpMLoCjKzifc20IQLJr1ttJtPWEn5Rov+Oz2cwlz2sXR9fPMb4dV850tqzxxO
5biUNhuEanREiyweZ3lzg0D1VMONWjKyb3hZTYBw4v6kcH7UcheaV2nYExH6tCCO
xuGXkSSb5KxRXcMxbNWLJSlxJXjF4JFL4H7cC5eOVSRhdHyKzvhERZLlsFnjH1+C
f6uqu8GSoiQt26qJpVR8J01Wee1YDHlfQ8P+OM2Rdzl9Bdm77d2Fdl5U35cpenio
gHmzIYtwsegFTQIDAQABo0IwQDAdBgNVHQ4EFgQULEfZ+uKFk9G9c7+8Y0JnOTDh
FQwwHwYDVR0jBBgwFoAUuw7XCigg8PycvO4e0eWhJ13lDKwwDQYJKoZIhvcNAQEL
BQADggEBABfmL8OaPmYnKve73x+h3i4e4D5Oc8i9I0EQ3sAnt2+zKcOVEBHcANb5
hjilGEqYZ7YWeI/ll6kYQUoj/ccGvqBmZRv8y/i5kyIZGRixDo4255Qg66Ubl7l5
4hFs8dfux86sBlrWQHnR42fQ6AYax3zzWp40vfDuXiiVsN5DJ5lFHWKy4hV15JDp
Px6jHH2JJL774MfXJhOFzfBh889g5bVlfUvs5I9kyejxDGII6bkUqyn9ivY5XODO
It9dgfbcCl8bXBz7hCThJs+o4gJTfUBO5YI9Kq3UYonks9I2eJ0H7pYxArG0m1Wu
4lhRYFkfhXMNnSutM8zzNSnjOAQHnwM=
-----END CERTIFICATE-----
"""

private let serverSignedByOtherCACert = """
-----BEGIN CERTIFICATE-----
MIIC6TCCAdGgAwIBAgIBATANBgkqhkiG9w0BAQsFADAYMRYwFAYDVQQDDA1zb21l
LW90aGVyLWNhMB4XDTI0MDcyMDA2MjE0OFoXDTI1MDcyMDA2MjE0OFowFDESMBAG
A1UEAwwJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
0/1V9rwz2eRFNwdsaVZXH6Wm0Vt8lPu7bPwO96Z4LNjbcOjPGDx2dRkMUXvnYwd1
B+dQ3dq+5tNhpMLoCjKzifc20IQLJr1ttJtPWEn5Rov+Oz2cwlz2sXR9fPMb4dV8
50tqzxxO5biUNhuEanREiyweZ3lzg0D1VMONWjKyb3hZTYBw4v6kcH7UcheaV2nY
ExH6tCCOxuGXkSSb5KxRXcMxbNWLJSlxJXjF4JFL4H7cC5eOVSRhdHyKzvhERZLl
sFnjH1+Cf6uqu8GSoiQt26qJpVR8J01Wee1YDHlfQ8P+OM2Rdzl9Bdm77d2Fdl5U
35cpeniogHmzIYtwsegFTQIDAQABo0IwQDAdBgNVHQ4EFgQULEfZ+uKFk9G9c7+8
Y0JnOTDhFQwwHwYDVR0jBBgwFoAUNQQu7tqwVgzhpoS5l8c8jVscMagwDQYJKoZI
hvcNAQELBQADggEBABBvwCD959xZ3Gz82UPBNxVRoz5hfwg2rrb4JcZHbKfD4gfo
M47YaRqHfecUW06WBmi4HgsLnimggjKQSiUDQGTuBZuotSpqJsj+7Y71MUYr8+CU
UJ+ejs1Ic2S65+GIu0+KxdEpzMfMA/mYlQRKmiETJ5xZXqtsLETdZZVbHPZN0BnJ
QKXeR6B8UCcw/XOtzc0TqQh3+V7gPx1NGe5y+E0xCwNgHtNGr2M4speAi2eb72qR
vlxbVMpIvlrdZV17Gi4CF5bwGTSxoxiNIk4zTwMJakDoDcPM463HBVYShQBJqsau
N3ySfzb5hhKWTBX665a0poEYTLlizf0GVfB5SLs=
-----END CERTIFICATE-----
"""

private let serverKey = """
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDT/VX2vDPZ5EU3
B2xpVlcfpabRW3yU+7ts/A73pngs2Ntw6M8YPHZ1GQxRe+djB3UH51Dd2r7m02Gk
wugKMrOJ9zbQhAsmvW20m09YSflGi/47PZzCXPaxdH188xvh1XznS2rPHE7luJQ2
G4RqdESLLB5neXODQPVUw41aMrJveFlNgHDi/qRwftRyF5pXadgTEfq0II7G4ZeR
JJvkrFFdwzFs1YslKXEleMXgkUvgftwLl45VJGF0fIrO+ERFkuWwWeMfX4J/q6q7
wZKiJC3bqomlVHwnTVZ57VgMeV9Dw/44zZF3OX0F2bvt3YV2XlTflyl6eKiAebMh
i3Cx6AVNAgMBAAECggEABeEFNMoEYBsSBlQo4AT6dpC3/x9b5Z/Tk1KsMZcGxyue
blOuhpwKpvWyX0Ih6R+oUbdLCVQLLkiXcSPMnpfIXd+iwAahboobVEJoYWjvxlKU
kt0DD2rXlpVF86SkVc9/XsS7KhI9Z+aGCbgapH8j9X4cO79lAjNXemnP7jvwseGm
HifmYsgzOqNoGIQsJS5diezmNHAmFeo0q577/fsQ0U1vnZkdTFUJF6ixPfQ5Wu/C
O/E1pZnjLjFKXLwxTq59jW9ayKhGNMCnLME+ytScSAF5yNIr2bKjzlzaPP05//i2
GXsfdn+3sjAsBAXB/XNWiNxDlIW+mzpb7KYZx3vs8QKBgQDx/EZmTnDiHw/nrjFw
gRsC0bYQr7Xzw54gevooBFeJNfavvtlUcFNo3s9bFt4SGP7J6D4bQu0LtaOV/E6Y
Z8CQCgbC6HXMpAWQqP4Q6vL2Hmi6YOh9ZWXyP3UrTjmwlolv0Z9BtLtx9/lAoz/W
HwaMIIL8Mf2TH8YLaXV0zkCtqQKBgQDgRFYQrodrSzd3YBEr1GepntLYkwzvX+dV
3qXk6mTeE58Fy3Yi7JEYcltB/Ynpin61bbpF9Fm72j9ZP1KwUjHMwFM8YiWFiq2l
z/C2vGrhl2biK5FMCJ0FSxFWh0AtRoRsbjE0+wTz5a6XSzYV/lkf1f7qnpEJ1OkE
VCWy/Go5BQKBgQDXlNrbNjLXILk4vDWLd1mrD03WW9QMEVCEu0q17/hUY2EcfTh9
Q3zrxuSQ0DSThvUmx+LcwqkQb4gHjTowCO7C5EvVxOd9ovraP9PpGofNwJWoxcEa
RgWm5eXq6Mv4iIR0vBnXnb4I8NR8Q3QRvJ5GpIhNSfQQ6JO1gwSDRWTV0QKBgCiZ
NltevPUXcLsTkQg2M23papH6TOUon2BUJgQCyq/JLYiHBKPd34ZlbU/M7iJxB+8g
JhBz46q2H7GwXO++cXV3e5n6yoAaUsUpl5H9GfwsxFs9N9hj1skWhdT8Nwn7Mg3P
BOlqZ8MfWTPaUbg5izjQLI2clvUIrgYylYCJYVFhAoGBALgcxQRSj+Zi9Vao/Fgx
3BfKMl88saz/77lbaHozTWi5W8FXPwZtDWfeAQexmYMZzzTh9bMQIoU2xL9RjlGU
tcvJX6MnO8zV1RxhudwuWP2jXH3/B3jwfzh1D4srdOJO6zxBWVIHWCyZaR+4MQrk
213NPjUNlKcqXrGNceXq+xu6
-----END PRIVATE KEY-----
"""

private let exampleServerCert = """
-----BEGIN CERTIFICATE-----
MIIC5TCCAc2gAwIBAgIBATANBgkqhkiG9w0BAQsFADASMRAwDgYDVQQDDAdzb21l
LWNhMB4XDTI0MDcyMDA2MjE0OVoXDTI1MDcyMDA2MjE0OVowFjEUMBIGA1UEAwwL
ZXhhbXBsZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQD3ETBd
JjWyfnV48vsU2q+gH2Mt17iIOgOpvbQwOzgo5Q6li+zVXwgnPQAH23yHguY61NpS
rEUO2+soCYE/19CRErTPJm1hWJpYXBdzR37vML6gkZ/Hi38JooHGzQgIvGatGnNt
YUQKtDx290X0P1dlkbubqJYM0a3a6fzrft/aG/hRxVXAdIMqYS5U+G7jB7ruruD0
/5l7l78y+hlV13OW5Mj9Hc9fA+mTrbGdWUtvcVBQ6EPkadmfp/bsK+A9JWEWo8eM
rZk4MOWxxrjH1buvRuftDME04/zCj3oYM+Kq0QIDU6Pa/e1Kioc2Fcc2zrq7Gtvt
awEvWxNwHbxAAL4fAgMBAAGjQjBAMB0GA1UdDgQWBBQw+Zc9GmEGX3mo96avqb64
ebA4ATAfBgNVHSMEGDAWgBS7DtcKKCDw/Jy87h7R5aEnXeUMrDANBgkqhkiG9w0B
AQsFAAOCAQEAA4mruZXxDLK+GevkI0bdptVGBx1C5O1b9W/qegAJJRZzRusK37mB
WX6MhOYetoWqrXtJ+BVROM/OySWoUrcs9QlhVbrITff5d9ffsO8dSddgg7274UjG
utlUgJa6UgkY9IfFZjOv05jbIt6wia1xUK22X3xdyFE+fsh3EJaKgeTlOO0FFK8d
5kYiyWgU3oy6jicgijAndRHfV+NcIlWCcAlxjfkGoymUOF170v4upzJPSnDcKKXA
5TW8D5sG0CAzFT5bEkIUZy7KQ7ojw6bhVrqsulC6QCCCQuYqDAqMnl74oOJAYdP3
sDO1dOpe/tz7nf0CJNDGVFaY5d1xF9p8Cg==
-----END CERTIFICATE-----
"""

private let exampleServerKey = """
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQD3ETBdJjWyfnV4
8vsU2q+gH2Mt17iIOgOpvbQwOzgo5Q6li+zVXwgnPQAH23yHguY61NpSrEUO2+so
CYE/19CRErTPJm1hWJpYXBdzR37vML6gkZ/Hi38JooHGzQgIvGatGnNtYUQKtDx2
90X0P1dlkbubqJYM0a3a6fzrft/aG/hRxVXAdIMqYS5U+G7jB7ruruD0/5l7l78y
+hlV13OW5Mj9Hc9fA+mTrbGdWUtvcVBQ6EPkadmfp/bsK+A9JWEWo8eMrZk4MOWx
xrjH1buvRuftDME04/zCj3oYM+Kq0QIDU6Pa/e1Kioc2Fcc2zrq7GtvtawEvWxNw
HbxAAL4fAgMBAAECggEAa4Ti976forCO3dZcNyyePoA6UKJu73XTz0Q7zLuQypc4
Qwn8RLUJHs5Ym5LEhFKOb+7enhjTKs7A7RkJ0udQIDo0TmvqMPF2pdpZ6DSmhGBB
rS4CizvlSqOad5IVm3ul8VIwBltMWZ4rLBibLFp+ZbjAnNKGjkiXsMugYjnCIC+u
AZNXx9aWaULosOjyieTIm0Jx488kMZubQ/eHsyzM2vOFubvFkGbZIou0Tbz3Y4sn
IZ2KysjCplQXIoW61I8GZQ9AUxJwGI+A9B6t8PZRYkRXh/JItxzGShWkqbfO6fm5
KY/W5huYd8zSlfDQdX1sOdG7AvgMQocRvFGGkL+VGQKBgQD79OEldzA5SiLEN05m
YwnbLYqe1NZaFAcWTvizQ4yM1UlzL4YT0lihRwvgExdkjfxG9SBWOkKOj9wS4wWI
cynCKcCVqZwrNWC7Hjh9zF2UTIqMnvTIkgcQNnUoLD/EHRwynaJu3uGJ7zQSm8OW
YHZYFqANBeHdy2HCNXCVWYcSCQKBgQD7CDjcSqnoeo5rA92tVQi+dSVX0qTkXP0Y
biS45m+TudyREJk7wbIRZOQkvl175nBAMxB0jZUY4pPjy/9cigjg9ysNo5U9o6vQ
OjPq9ug/XUNLb/iBIXJ1513szcbLOg7GfZBZxf6gpDBV3wGdNxuLR3dgXPtMJTcZ
6mWtVyG45wKBgG1Qd4abya5xfdgH7tn5SkNv5N64lS+L1O9W4AxW2FoaB74T9mYP
Myj1/C8B2XplJ/lZTOhcapgTznXbTYFABfQZzVahugH9LLTCjdv2mPtIoiwUozuK
L8pW9kmxuRDLWHqVbe4QgWYpBDy2nAtYWsApQNOlo7NpFEcAjJIfv7yRAoGAdaZ9
16jahs1hkAAo1cKjrXeDv+xGQYzfRaLhbRL6uhaCrC5GUr5N8V8CmcHqWFZAx6Xn
EWkFtrsCKuIB1WIQFTdiIytGl7Pso1OT34xGfuP71RAuPH7rgRylZYVvpPGZ2Sci
DyD/XFR3Hte8ju0z6IvfA/ewAxjyASBc9OeAM4MCgYEAmhGmc0EpFxcR8OVbFDuG
3ZITjf7riyJDHai1/5hTaoJCH3OFEh3ztShY3Oos3P2IiApNbAmy8qrybxTa2KSJ
NhAe6b+3E9TF5JnrfUPGNNhNKuqtV1eGeujhT7Le2JHk8nB37ehzxlm9eniGiL6C
e+iul7j1acy9WAzAMM2yolU=
-----END PRIVATE KEY-----
"""

private let clientCert = """
-----BEGIN CERTIFICATE-----
MIIC4zCCAcugAwIBAgIBATANBgkqhkiG9w0BAQsFADASMRAwDgYDVQQDDAdzb21l
LWNhMB4XDTI0MDcyMDA2MjE0OVoXDTI1MDcyMDA2MjE0OVowFDESMBAGA1UEAwwJ
bG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAyk9LkZPl
QFsEqRpL7G3sodr994+S6c364WajthRUQsv69lJOurmEnA/JDekcLUEcVySOI5wR
bmJ0hKgvfsmTRMx1v5NfOOAA/y9AiNZcpd/HLzaKGEYtqmw26ojcv5GYm9yqXMT2
naw8V5l2GHVoQQdXqCRzd5CRWJl9ze1kqMVNYnex/EKKQDXv7kfGt2raB3WF7S4k
EH2nahzjjoQ63/UY4IQaKiNxbalC5VwIuu9k2Qm+giWKyPJ+IxFpXM+2OcQoSZKe
vMj1UeAhinxXz6/HMshA7RiKFfRmwVasEd12v4JzPLOa3LEp6y+e0ibyB0RzSLyG
YzCqNI/hbIZrGQIDAQABo0IwQDAdBgNVHQ4EFgQUpPAVeogyMNdXKD/TazJFsgDx
UKIwHwYDVR0jBBgwFoAUuw7XCigg8PycvO4e0eWhJ13lDKwwDQYJKoZIhvcNAQEL
BQADggEBADqEVyhg7bA26yAhfv90754i1izMpjChd7yH3zgE6/BuaJ+dNoxY4LOx
p5EWatGGQkhI+mPuaVQ39T9q+S6TW0icjAsXZxXnpK1usVmfmb8UJhvnEwNmP7n8
SMcYPGEUGPdZjjb86/NXwgp9iOcwRdPzkltqL+n1stI+VoYNfhBkhkUF68+XH67K
1UkjzxUKd0vJqiv0sSOzHuAyoiwgJ93FgTk90kp5jW2lru3mYdSoXKbMmxKkSmyU
pgMctshh1Ps9Ts1yrng/w542MG1XrPyhaLBwGH3E2OuHZHV4M0UvJ2XHjnPthASN
PFHeEB8Jed4SOWlxjQn5sfF3GzIznWM=
-----END CERTIFICATE-----
"""

private let clientSignedByOtherCACert = """
-----BEGIN CERTIFICATE-----
MIIC6TCCAdGgAwIBAgIBATANBgkqhkiG9w0BAQsFADAYMRYwFAYDVQQDDA1zb21l
LW90aGVyLWNhMB4XDTI0MDcyMDA2MjE0OVoXDTI1MDcyMDA2MjE0OVowFDESMBAG
A1UEAwwJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
yk9LkZPlQFsEqRpL7G3sodr994+S6c364WajthRUQsv69lJOurmEnA/JDekcLUEc
VySOI5wRbmJ0hKgvfsmTRMx1v5NfOOAA/y9AiNZcpd/HLzaKGEYtqmw26ojcv5GY
m9yqXMT2naw8V5l2GHVoQQdXqCRzd5CRWJl9ze1kqMVNYnex/EKKQDXv7kfGt2ra
B3WF7S4kEH2nahzjjoQ63/UY4IQaKiNxbalC5VwIuu9k2Qm+giWKyPJ+IxFpXM+2
OcQoSZKevMj1UeAhinxXz6/HMshA7RiKFfRmwVasEd12v4JzPLOa3LEp6y+e0iby
B0RzSLyGYzCqNI/hbIZrGQIDAQABo0IwQDAdBgNVHQ4EFgQUpPAVeogyMNdXKD/T
azJFsgDxUKIwHwYDVR0jBBgwFoAUNQQu7tqwVgzhpoS5l8c8jVscMagwDQYJKoZI
hvcNAQELBQADggEBAEZ0tQZ5tvRAbahuIgAuxdD1mk/cP4frxlrYpBxjfS5tZZwI
lVYlrRbGeg/Ywqks51f5dvXZp6PxnOAPuqO86id2VQLYbTGRPa3cTFJcexmriBZc
Cpeh+o1bkvG6RrHNVwdf8kBc45Nxqk3KJOTs6r4YdzagqEm914utKOHDb7LnTthO
50ipeebNF77S3eFfGId3xlnvgnyKkybUmRudphFm2ptiQ4vxrLND+BOohtdlY2IL
ABAwUVXzh4nygDo1jMNEOevSq5iuM7Hg0rGlkx1gZsFPAq3kkDnd0x02dxbnRWjK
FxGhqC7H0fkzy84mf1malmWB9ghbJQGLHWEygS0=
-----END CERTIFICATE-----
"""

private let clientKey = """
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDKT0uRk+VAWwSp
Gkvsbeyh2v33j5LpzfrhZqO2FFRCy/r2Uk66uYScD8kN6RwtQRxXJI4jnBFuYnSE
qC9+yZNEzHW/k1844AD/L0CI1lyl38cvNooYRi2qbDbqiNy/kZib3KpcxPadrDxX
mXYYdWhBB1eoJHN3kJFYmX3N7WSoxU1id7H8QopANe/uR8a3atoHdYXtLiQQfadq
HOOOhDrf9RjghBoqI3FtqULlXAi672TZCb6CJYrI8n4jEWlcz7Y5xChJkp68yPVR
4CGKfFfPr8cyyEDtGIoV9GbBVqwR3Xa/gnM8s5rcsSnrL57SJvIHRHNIvIZjMKo0
j+FshmsZAgMBAAECggEAChIgMIUglX9qaBoUYza2H7kBaTZLEYs0xM1pkx3oM2KI
0cP3YhVr1+Jzx1beNZT/Con57uUdG4X4Z6WhJqI1a+hzKJgXFoNVHV7eayljl4jA
FzYzceGlco08PxjUx08BvimCDAfsgF0TbGdp4O4QRGNvjkHRQyeNyq+qWurJNtrz
1SK7ziypzDgnE8Q3hJadO9yWozmZ14OqCPR4hrzGgFPz5zz17gGapi58Ux+R1lE3
n9zpQw3g73xpO4y1KBZsElBkgHHAZBgScS8+Lm/N2NUwwxZRFWkDWPLJKqtfY8TP
UaI+cKboj6e3LDlsfW3n+BoTnVt3rAnOThU6AY9FYQKBgQDpB0kfs36LgiNSwAcl
sVElULUmvhQvTso8bmSsAM9+19/C8EhelWKXkHtEluv+C/8uMrEM0Oon02amO78G
ojnaNPFkSKuD0/ieGB6NbOyiivqq+MroEMxmP5zZB6fTLD7gYnbRvcZOMwVGEYr3
IH80Nldyg8qS5buCjAJKMkcx4QKBgQDeQMqBseidENfikJAJ05qoF4J377pEFMpv
b9r7GutXS/5JVrdypTg7SsNK7x06pcDF2h/VHVfpT6l36u+nVn/+MZz1jQBsvJ5G
FE0rG6FScZlzqPhXTYDIgrEeXBMRqMKCl+Sxo7PGEjit9JwdSJxwnEI7/YGMu4oP
WeJNadZQOQKBgQC5AzjSe49wMi3baG0ERykXCGIbVXTvLo4wtrElQyt7GOgmfOHo
fpCdp2/HQFA0DtBWnJanh0MxxY1NVEhRewGVts0lAvFyJBzTYHD5dk7WqqNklU18
PMIcOEtOoN5lMk7llieiVRsaQTXhsNH1bY6xJKf/WpW+VbmvZ3v17r9J4QKBgCgN
3zEeggCEf5O6X+sVcqLmkcHRt2z7njwVGY71nAJAlNRcx3Tm58pvv+BqVYczRhmi
JOiAgE5w5+bPtV8gDLMf99ydC72NBK02jW2+bgVwqaoZgqAhPJtmSkthZqJhGqT0
gOeuzABfWk2nbtcsNd1pm9o55rYZOlln5ovzDgepAoGALJWZQKSclb0hGJLL9dNP
JK7OpXUMcska+Jm98nlRUwh1gZP/SIfZlVaYC7sGKb4oyoZRwDIyJ9WT42LvVnMb
fT4CWkkvhC8HPIQVlPS2Qtjf3vwQozzAZ1G6dc8qkOe/ypb9ouVqJn+HEdufaFpQ
4/B7TZKyKxbAEIBm8M28cWg=
-----END PRIVATE KEY-----
"""

private let serverExplicitCurveCert = """
-----BEGIN CERTIFICATE-----
MIICdjCCAhugAwIBAgIUEhFu+6dIztYWjsk3W4hNZytHsrEwCgYIKoZIzj0EAwIw
FjEUMBIGA1UEAwwLZXhhbXBsZS5jb20wHhcNMjQwNzIwMDYyMTQ5WhcNMjUwNzIw
MDYyMTQ5WjAWMRQwEgYDVQQDDAtleGFtcGxlLmNvbTCCAUswggEDBgcqhkjOPQIB
MIH3AgEBMCwGByqGSM49AQECIQD/////AAAAAQAAAAAAAAAAAAAAAP//////////
/////zBbBCD/////AAAAAQAAAAAAAAAAAAAAAP///////////////AQgWsY12Ko6
k+ez671VdpiGvGUdBrDMU7D2O848PifSYEsDFQDEnTYIhucEk2pmeOETnSa3gZ9+
kARBBGsX0fLhLEJH+Lzm5WOkQPJ3A32BLeszoPShOUXYmMKWT+NC4v4af5uO5+tK
fA+eFivOM1drMV7Oy7ZAaDe/UfUCIQD/////AAAAAP//////////vOb6racXnoTz
ucrC/GMlUQIBAQNCAASHfeOIZlrc+BdonIMCZ0FYirqKGwHyrPONGXeU5fbi8Qpp
Znr4tkgcHXs0mm3LPAFtvxLAdI+UjtOlZd2b/fi/o1MwUTAdBgNVHQ4EFgQUzpDC
GzftjDa6oEyeHawytyeJHKMwHwYDVR0jBBgwFoAUzpDCGzftjDa6oEyeHawytyeJ
HKMwDwYDVR0TAQH/BAUwAwEB/zAKBggqhkjOPQQDAgNJADBGAiEAmxa4eQTCbKGt
kZFhZjbgNJhstHPCRG1HeU4P7PgiTwMCIQC4fPOdsO4wptaBwadQQo7QvuDYaWYI
nEyZf64SLpplsA==
-----END CERTIFICATE-----
"""

private let serverExplicitCurveKey = """
-----BEGIN EC PRIVATE KEY-----
MIIBaAIBAQQgA2RFjdUNwBPcPA49GcuVkrij4TYwci+/M5t9FH7uT4CggfowgfcC
AQEwLAYHKoZIzj0BAQIhAP////8AAAABAAAAAAAAAAAAAAAA////////////////
MFsEIP////8AAAABAAAAAAAAAAAAAAAA///////////////8BCBaxjXYqjqT57Pr
vVV2mIa8ZR0GsMxTsPY7zjw+J9JgSwMVAMSdNgiG5wSTamZ44ROdJreBn36QBEEE
axfR8uEsQkf4vOblY6RA8ncDfYEt6zOg9KE5RdiYwpZP40Li/hp/m47n60p8D54W
K84zV2sxXs7LtkBoN79R9QIhAP////8AAAAA//////////+85vqtpxeehPO5ysL8
YyVRAgEBoUQDQgAEh33jiGZa3PgXaJyDAmdBWIq6ihsB8qzzjRl3lOX24vEKaWZ6
+LZIHB17NJptyzwBbb8SwHSPlI7TpWXdm/34vw==
-----END EC PRIVATE KEY-----
"""

#endif // canImport(NIOSSL)
