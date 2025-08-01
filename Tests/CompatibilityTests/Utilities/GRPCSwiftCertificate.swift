/*
 * Copyright 2025, gRPC Authors All rights reserved.
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
    notAfter: Date(timeIntervalSince1970: 1785580036)
  )

  public static let otherCA = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(otherCACert.utf8), format: .pem),
    commonName: "some-other-ca",
    notAfter: Date(timeIntervalSince1970: 1785580036)
  )

  public static let server = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(serverCert.utf8), format: .pem),
    commonName: "localhost",
    notAfter: Date(timeIntervalSince1970: 1785580036)
  )

  public static let exampleServer = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(exampleServerCert.utf8), format: .pem),
    commonName: "example.com",
    notAfter: Date(timeIntervalSince1970: 1785580036)
  )

  public static let serverSignedByOtherCA = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(serverSignedByOtherCACert.utf8), format: .pem),
    commonName: "localhost",
    notAfter: Date(timeIntervalSince1970: 1785580036)
  )

  public static let client = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(clientCert.utf8), format: .pem),
    commonName: "localhost",
    notAfter: Date(timeIntervalSince1970: 1785580036)
  )

  public static let clientSignedByOtherCA = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(clientSignedByOtherCACert.utf8), format: .pem),
    commonName: "localhost",
    notAfter: Date(timeIntervalSince1970: 1785580036)
  )

  public static let exampleServerWithExplicitCurve = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(serverExplicitCurveCert.utf8), format: .pem),
    commonName: "localhost",
    notAfter: Date(timeIntervalSince1970: 1785580036)
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
MIIDBTCCAe2gAwIBAgIUS9Gnn3rVEfG+XVcoeTikW8hWVTkwDQYJKoZIhvcNAQEL
BQAwEjEQMA4GA1UEAwwHc29tZS1jYTAeFw0yNTA4MDExMDI3MTZaFw0yNjA4MDEx
MDI3MTZaMBIxEDAOBgNVBAMMB3NvbWUtY2EwggEiMA0GCSqGSIb3DQEBAQUAA4IB
DwAwggEKAoIBAQCNVRdDRrLOSBiVfBS0Og5P5zI0EmrczOeUwm5YulPcIfqFB+oG
twBmyYTuVB2WkIZvEBTuzyhKA5UgUe+s5b13snK13cRVF4fmPAukSePEkeSNL84s
YNGW9YzA/NQqDrOOUro1lvlzVDc4Qqzfh6DJpIH0pnOEJKWWA+Bm+bYhnRyfz/ag
JF087/mVVwARu43tmRFA1hqC8H7G01058a+mkdartb0FRqj32OLZWNagLpxdEHNY
FV/VYcdAwBscPSYxeE1Ty6/puA80gTyKMjZRySNEaOZpZVu3jnhz+6S5WLGE7+gr
m0VsZfgrW8hkQ9iXkWQgVVRec4BPj8dm8pffAgMBAAGjUzBRMB0GA1UdDgQWBBR6
gAyhADSZB99yRbrHuIj/VO4N/DAfBgNVHSMEGDAWgBR6gAyhADSZB99yRbrHuIj/
VO4N/DAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQAq4Lr//8d4
OPObQWOgEj7CC7zSIaCuuGrhMSHL/4D4Ed4zJg/5tmOs0StzbeQuOshCA2NANyfY
0FTcqXpnjer9/9Lgi7J6x4ZrFC9UW9svFjp1E1FlrrtDQJoBJrnQLbLHz9BUQ+cV
8DHtVeNW38rBDlRhxYiRv4Tjhg9cVG4pM+FOw83i91HRPFdleJN2LM2/mNZZg5tU
uTj69QFoT43CuPV1E7x1mSu7yauUU6v+5e1rzQ4wSPqytW3pFYPlKB2MacapdNKv
qkrs9Nju5LWaMOkaUxNL9M0s/5RrBs4r8KegA4+50i0vHwWNJid38AF4T8c/Wx16
SUHlQmj1iNPE
-----END CERTIFICATE-----
"""

private let otherCACert = """
-----BEGIN CERTIFICATE-----
MIIDETCCAfmgAwIBAgIUG1BEAWMUfjwSnMVhw7qISD9MUMowDQYJKoZIhvcNAQEL
BQAwGDEWMBQGA1UEAwwNc29tZS1vdGhlci1jYTAeFw0yNTA4MDExMDI3MTZaFw0y
NjA4MDExMDI3MTZaMBgxFjAUBgNVBAMMDXNvbWUtb3RoZXItY2EwggEiMA0GCSqG
SIb3DQEBAQUAA4IBDwAwggEKAoIBAQCyBegbhOdHXncCKIWQxApLGP6rFnxsE4e5
ADCpEbL859iz8cIeo/obpBq81okB1ctr4DfaZLFJyMD5N2hVbjmWrrka22/2CaOJ
assCvI+X+Ms0DaVCiNrKGQhSUcUy1H1zut2MR4Wqzs8hOgX92pKXTy9DMF0NUd2b
aMmKjDUiqTKjXKI3mhYtpTAglpmbbJ4NTdaC9oAHcj2QfAeB7V22lQu78M5VuKqX
yFj9Rzu1UpyqCYJGUPLeIrBCrEmo3G1X214D9TDFiEDrclS/uCart75eJF4mi+YK
bCH8ZFYHKfHLRAnbmj5S1iUQLRrMz3M43+wDZNBBm521wX76nO+ZAgMBAAGjUzBR
MB0GA1UdDgQWBBSt82wmVwsvES/gvs1jwOAxv7RUxzAfBgNVHSMEGDAWgBSt82wm
VwsvES/gvs1jwOAxv7RUxzAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUA
A4IBAQABshc7CETXkCuexRbBADG8OkUQV5r+GQ9QtlQLr4ErGxQ68IqMyQM9ZV+i
VCuYbimlLFDyk85nxIYM5coXc49rWX1HUjgml4w5592hiRcEoY+Orf4hMsX6NLi3
Mcu7wSu+u1kqlNFfLfXubUQHmAoFMdIvuub/F2R3mWzo5RvBJS5cKHV7CwcGvk4V
Osdd0jWANDyXrzAFAu4+JvC6cdv0cUpZ/EkJr+kvXOq6XKg7mwBrtMEGrPNaTTqY
R69aQ+3a708U//lsojOf/62CwR58Nf++HNAmtemUTPBifoeZRZ5xu43jV+dz0oct
bEg7XwkUYX6bigJ/PYYtMhh2dx/q
-----END CERTIFICATE-----
"""

private let serverCert = """
-----BEGIN CERTIFICATE-----
MIIC4zCCAcugAwIBAgIBATANBgkqhkiG9w0BAQsFADASMRAwDgYDVQQDDAdzb21l
LWNhMB4XDTI1MDgwMTEwMjcxNloXDTI2MDgwMTEwMjcxNlowFDESMBAGA1UEAwwJ
bG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAuYpwFAQB
Ml5jVGLO3buHXAQCwEQGPtLWGYGvo6V9EGbRA3Ti8WQbGN53osCOKgYSEx02BZ5v
DbbYi6E9+Igh5cZloUZ5bCcaecxpk7xZvU2HF0+UQlYeFhQpDERXDfE3wiSV5SqO
RzZjJ+ktxm7TsDee4QLs1FNfzL6eGfmeCM1+3e4UY0Nj99Ozma7pQQMfB00patA5
4JWMkiVbvmr/6VBkcT7xqrj+a16jvCClHdPP7fzBJttPyIgHi5LO2dU4/PCjKxQR
MyEahq1LkApa2OYaACqZqOMEHa3+/pBY78VMjaTr6or2N4jrqXsKnLJ/lVTmqKXU
4bR6nlBBg/we4QIDAQABo0IwQDAdBgNVHQ4EFgQUYT65GQobM9CsDwKIW1NoksRx
MtQwHwYDVR0jBBgwFoAUeoAMoQA0mQffckW6x7iI/1TuDfwwDQYJKoZIhvcNAQEL
BQADggEBADgq+ob+iiK3BkDmgjZ3nQE2c58geyQvZ8ZJSTlexpUV9wpOlVEN556Z
AGMqK5IxtUajwG27QqCWUhCymOYFNAG7VZH4LDgcScPTbvR34MqoaNpGk2Xh34Xa
0C9MqxLUPRr5q8F2S31IR7hQjCwLU1xg2in8J1ucWqcZtaeBumRJurOYKnPgOrsq
OetfdrwlwXi1EUMWDIhxyKbznFvWy5usbYA00pK29Dr8N0N3Vjo982Ut1zseuKk1
uYHxZrhQHh5njNDIC6f5igvptnFo/Z5DsYIqsALO38MFbpjCKAGnEBZu/EMP7Ub6
+IONyrkbd4pKsVBysEjAaS9zBxbYO8s=
-----END CERTIFICATE-----
"""

private let serverSignedByOtherCACert = """
-----BEGIN CERTIFICATE-----
MIIC6TCCAdGgAwIBAgIBATANBgkqhkiG9w0BAQsFADAYMRYwFAYDVQQDDA1zb21l
LW90aGVyLWNhMB4XDTI1MDgwMTEwMjcxNloXDTI2MDgwMTEwMjcxNlowFDESMBAG
A1UEAwwJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
uYpwFAQBMl5jVGLO3buHXAQCwEQGPtLWGYGvo6V9EGbRA3Ti8WQbGN53osCOKgYS
Ex02BZ5vDbbYi6E9+Igh5cZloUZ5bCcaecxpk7xZvU2HF0+UQlYeFhQpDERXDfE3
wiSV5SqORzZjJ+ktxm7TsDee4QLs1FNfzL6eGfmeCM1+3e4UY0Nj99Ozma7pQQMf
B00patA54JWMkiVbvmr/6VBkcT7xqrj+a16jvCClHdPP7fzBJttPyIgHi5LO2dU4
/PCjKxQRMyEahq1LkApa2OYaACqZqOMEHa3+/pBY78VMjaTr6or2N4jrqXsKnLJ/
lVTmqKXU4bR6nlBBg/we4QIDAQABo0IwQDAdBgNVHQ4EFgQUYT65GQobM9CsDwKI
W1NoksRxMtQwHwYDVR0jBBgwFoAUrfNsJlcLLxEv4L7NY8DgMb+0VMcwDQYJKoZI
hvcNAQELBQADggEBAFXw7cXMUeqtZb0GbLweTOGx3k6m1HTqMBe1FJM40HLYAfXm
UkAvAdBNRrP2l/faL+1teZWfkcChHVKexjRcOXvuEU155brWgICrW2rirZ4rTDSx
hGjyRAdlfK+N6HDi8gd246kzqRngim+o/Y26dzKKwEDmEl98sW2Xbhz3H1lMpJmd
fOIyTphvV3Xb4OtzcIUfH0eJlOQKBbMn/wndPwhO0iI3iVc+XObZyZORwbiCrxxB
l199e6OSJOxSlTdR7yDWLQFBVfeI2YChK09yO+F39C6g5hyTGOX8PhuTwldbKb3e
1ORFIA0UoyGNG3ItfTElsuRh5KOE05ZdXRHbp/s=
-----END CERTIFICATE-----
"""

private let serverKey = """
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC5inAUBAEyXmNU
Ys7du4dcBALARAY+0tYZga+jpX0QZtEDdOLxZBsY3neiwI4qBhITHTYFnm8NttiL
oT34iCHlxmWhRnlsJxp5zGmTvFm9TYcXT5RCVh4WFCkMRFcN8TfCJJXlKo5HNmMn
6S3GbtOwN57hAuzUU1/Mvp4Z+Z4IzX7d7hRjQ2P307OZrulBAx8HTSlq0DnglYyS
JVu+av/pUGRxPvGquP5rXqO8IKUd08/t/MEm20/IiAeLks7Z1Tj88KMrFBEzIRqG
rUuQClrY5hoAKpmo4wQdrf7+kFjvxUyNpOvqivY3iOupewqcsn+VVOaopdThtHqe
UEGD/B7hAgMBAAECggEAFGOF3vE0t3X/WNPV0zBrFr27Fqky/X7aN6nUZPmHxYBi
6gwTbz7WqnQx9eDOjoglvtN4LwRixEFKSQfCQVgmT3NukhsmNzAR3P4NQQaS3vZQ
yMs+Kc8AVeFHxHkTDu1puOwfy7PSODmeClH5rYNawFPQYf4aC9gQoDV3NrgDOYi5
exoQ944k4Z71+52kXPZp3QntQmu+yESWBCB26K1DuD+jnXID3CNIjwN8K8Wm/ask
3K8fmnAzVyAqAgwst30JMBl5wNsRHM8V7BGB87nSpndUHrdHA6HId9J6Ieg0wkCm
6ATrOGAnZGJS0dLuJ5NIKbP97SV/W8cvVgUNcg3H0QKBgQDkgZ1t3jAZFj84I0UH
5wrpNOxbtWm4+9/msOUOqjN5b4GsAXlSjnIfeYDR7dQPTD5xLj0HNzz7qx3yerrW
PjoUeWyIEmsWDdsbPtvg4/DeyD+ofCfM4ITod0iW/aINZpaJyIYJVPf79b8wFhas
HddAJ/bTwhGwBOiODi934OVVqQKBgQDP3WkvLPWhf+TQipdGQawcSHRlpoGObWs2
JftZAkJxHttadNm9Npgfx9t8E0jDcxPD1TFwh4kCH4wK6N1Y2qzP47WFcyaxnwhH
j0mgckpdtOL1f/HIVWqE6x6AK7egfE8YDwmsP83MVoETk2alF20SDVdDEhvMu1z4
HgtRjALSeQKBgQCRuN7uq908gmV6pXNmYL8ija+VpJFxeJ8G/RR2T7BX5vZo/N+j
+FdrHw850VOFFfhUMUqWCXIIhM2qTv5Llo9vcyf1dtl3zQpHy8RpHLQFPurpxZOU
IjJgFYHjWIg5x4yE/a4M0XT753IvdkarKLSWo2XTEVY6TEcKIJ3A81kNUQKBgDYp
BqMYH9g4rrH3qnrP2bx01H8350HpGKo/M0J56D35QEZNc/5tHy4IsROfIrJqZZf9
EKi1Z+l5ts+Q5Tulnql8N2vSGR7mxQ2ANDruDJpl60z0TVdZiiuf546V1X6nZSRr
pqWO6lx3naIwIeqaM/0kJLyBF2U83Hh5u5E/3exhAoGATWnYvtP9eGdMTgfzXFS4
AOgmkaQAyz9RznCeICBnYDoUCU4o/fkkACW3IXHZRCDkiwLpLyUBNPHvN+tFPTym
liVbXUtn3h6Jj4kiXShNVYTMYv10mMCUuGBkur6XrzbNZ7NyGX0jkOOgKgiV4txv
lU5aIidtMhoAKL+tJj8gt7M=
-----END PRIVATE KEY-----
"""

private let exampleServerCert = """
-----BEGIN CERTIFICATE-----
MIIC5TCCAc2gAwIBAgIBATANBgkqhkiG9w0BAQsFADASMRAwDgYDVQQDDAdzb21l
LWNhMB4XDTI1MDgwMTEwMjcxNloXDTI2MDgwMTEwMjcxNlowFjEUMBIGA1UEAwwL
ZXhhbXBsZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQC3l3V+
o31V9CspXKzuBrmF+0Uh78aozaGNaRCYNNkf8mwe3ul6IjOCRXad6lWF/3Paid09
SyjR+0UDJdUMqX9nbd2d2gG2zeBwj5FDYA3sCdp9BQKuiBq+ZA/XStynaqCMRGjo
6RddNeRGlu+CBvIhEef8Ek51/tj0ypT57Hku+kSxac1g/CPwB2iPd5w10pKtTiQM
IOIXGacyjZyAHqxPCF92ZuOXNGd23JEmS0iGo4nLHJIFgsc+ePMsCE6tjzf2TmOk
LmBNxMPn0xddZWKJQ5ddNrsH5+HwD+sGWm2tDgTDABx4U7K+S2kX68+GT0RnwSkP
er2dG30mWs6NrjeTAgMBAAGjQjBAMB0GA1UdDgQWBBRz6mtMRVrzcpqDVSnwGmRN
YyN+rzAfBgNVHSMEGDAWgBR6gAyhADSZB99yRbrHuIj/VO4N/DANBgkqhkiG9w0B
AQsFAAOCAQEAAlIeye+KFjZTluv/7IlXPOVq91Vv8DkSP+slmm2CYa1QpblTTJyN
Sgn+OKMXotiHhB1NoxAYe54Ry6CpdPvuUw8Gk9omG/H3A/Roi82sCKF4uDpA2Ip6
v8MFfVf3oLVdmDY+R7oAcEC0ai4cFwEkOdkObitwHLXlgM4D2pSAfSwQSpr/gMwM
8TAkoQ4N1P84mlv5Wgv6yh0vmpJVRRckyVzxRlUXhaag8nhWu4og2lMUlTC1uBdt
5zAGZFbremzuz95DNkNFKwkU3HBshfTNvSHWA8+P2cXeDK8E0m3CDgqlbqIM8gXB
L2X1EKZxQjU7EMafY+5FNGSYfxPxwX04+Q==
-----END CERTIFICATE-----
"""

private let exampleServerKey = """
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC3l3V+o31V9Csp
XKzuBrmF+0Uh78aozaGNaRCYNNkf8mwe3ul6IjOCRXad6lWF/3Paid09SyjR+0UD
JdUMqX9nbd2d2gG2zeBwj5FDYA3sCdp9BQKuiBq+ZA/XStynaqCMRGjo6RddNeRG
lu+CBvIhEef8Ek51/tj0ypT57Hku+kSxac1g/CPwB2iPd5w10pKtTiQMIOIXGacy
jZyAHqxPCF92ZuOXNGd23JEmS0iGo4nLHJIFgsc+ePMsCE6tjzf2TmOkLmBNxMPn
0xddZWKJQ5ddNrsH5+HwD+sGWm2tDgTDABx4U7K+S2kX68+GT0RnwSkPer2dG30m
Ws6NrjeTAgMBAAECggEABF5SGUFEip3nleuv1YXoQhtKoGqYqkxoeRaC3ORLNiCe
cBUQaOAPXlbxytSYMV3R72VTNtePq1H3aQJDq9UM1bSyq8RIKbRseN+7HP61QEdt
YRKf8sGn3IZZFlQJMFZv8rZ7RjTw7YQtQwiMeQlDAEpaAufgbOGzdiXaO1rkJ3kD
F48UF1SKs0Pd0ssRjBL0BuhNev04T+LJJz6o0ym4yiMWlYg1ddYx26sMX1SSFF6p
QMQDGcI8aXo3LTfMxp240w7DuFIwe+1Y+WfB8OwwZ8hGQVMuYElntNS0FPXbp8Mq
/+SSt2XTx2XsRu2OwU5cBb1X4yqAJo/arpt+DXb/8QKBgQDzGEYG7yZP+70b20Hb
cQRw7J2tVm+wdkRUfpra96mzhBlho6CToWvWvbpc/RJbjp6dqXZ52h7cKV2lZoC6
ANJwu5hLbTIlb0KsC16zZ73Abw6V5aEuCuFrNKdS1cUGGvlnHrBAOq6vjJuGQtKN
9cPa/8DzyMU/OX6FtUl666hscQKBgQDBVoVDsACFTH7VLkMGOW/NeDGa63ugb9+u
b6gYKLntx47y21Z3FWHRhgqf4Wb1dJpncjPlHz01AtdOjRVLE1kj1uoU7q+B6TbH
uN/7HF5t1eR4JFVQe+iFELEphA5rdgHs12KWRiqg5aNfkeKp5hXgJAsxmnV2VbP/
xo3P2lo2QwKBgAjNVzPHEwcQYW+Rx9evRu7j0m3FVHP6RE0e7HKDRzTF0rlzWEwg
KyxyYD4ft7ty9ZFV4oFVAYsNQGPNy1lw0C3ezQvmH0u1tJ9QJhSu6/L80nVhBC4L
nM/p7ykTrnejIGa4eL9KoKqgl70LzF3xiS7z1cO+AE5iwY8L2mZGBCoxAoGAPSbZ
pewwbfkhENq+FmTqaQoAXqjnBHr+PBVTDLks/fmlzEj2E1pvAy+rgqBvyWllQR0N
LwZvfKn2YgEb4BAxnLVoetB4MNYMHqXqKmnxsDn8Nsf/OCLJC/WYo7ICQZkkyL3j
j/aHmzanMx5YnDaLasbbx4e8aX54HYm25yyAZjMCgYEA8RJABshkPwQLpAGBOlfC
sxzo/Ggqc36BWVTqgokJnGArVnxUZH54rAN/FubRbT4G1QfFnIYBAwfD5w0t6RIi
gBbYcBChmboR7J8IM81mp/f5ydf7/vOfvHkk6iJ0AtvADYgPD4Sm4u22KYQ/ydSp
8tDQ5sYKoI8F5kCi9xU1jcc=
-----END PRIVATE KEY-----
"""

private let clientCert = """
-----BEGIN CERTIFICATE-----
MIIC4zCCAcugAwIBAgIBATANBgkqhkiG9w0BAQsFADASMRAwDgYDVQQDDAdzb21l
LWNhMB4XDTI1MDgwMTEwMjcxNloXDTI2MDgwMTEwMjcxNlowFDESMBAGA1UEAwwJ
bG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA03hn7w6V
RXwgfD/AZSX479gmUjBi7KmWHLPXmFpDqxiwI+b8B+QkcX4i4CvHcytFows2VY3a
hOt4mEXIuFmG4oKCRDmeFb4rWlzMC2psDb5rvlwHOCJz3e07/l/S2S+4LbLmsCYO
6ZpKqE/PTTkyyGZEAethnLEtg2UiPWhsi1CofLRTQwOqOlEWDydT7gfRFQgX2uo8
DcjRqcG3pIqzuaCYKfkVIu/8bQBF6Xqn16KBovBEi3pBs5KE5Z9g+gAYyMG8BPqi
cmqxmVXc93NsrEbRnexbYAFZIIo5hbIytGMTT5NsufXu9jcLlRorxgtWqQ3I/q7O
4ax2iiLExU3uoQIDAQABo0IwQDAdBgNVHQ4EFgQUpCB1gxY2Rr4j7cuH+WWLrwu6
YqcwHwYDVR0jBBgwFoAUeoAMoQA0mQffckW6x7iI/1TuDfwwDQYJKoZIhvcNAQEL
BQADggEBAGYqD71YzJWZWEeg+jtG2GiyKz7N5hwdSAp2O03mWrGIpx+26m8rrOLN
Daa0CDw8WI7owLe3+UJipGufgWFh1PMvnzZvSpgMnQjfyOuOTDw1TBe8lhiyknQr
DfmcCnGoRXqicaoKdXKbU+RFsbxdUv/Ap9p7uuNxDy7knwid95cKGV/+YHygc4NF
/73ZtsaOGJKsRO/3NtDObPSjkhT3x/XzFRPPKLhf03td5xmrPXpwRpym9exafKLt
PUKbP2j0L7uiaOLCiXeKoCo3BlxW/UGIpRT/SijpMUjeUA+8JVioXWSej2+k7CQf
iSayeE2RmpLtRF3EKvj39rhZJwjUmms=
-----END CERTIFICATE-----
"""

private let clientSignedByOtherCACert = """
-----BEGIN CERTIFICATE-----
MIIC6TCCAdGgAwIBAgIBATANBgkqhkiG9w0BAQsFADAYMRYwFAYDVQQDDA1zb21l
LW90aGVyLWNhMB4XDTI1MDgwMTEwMjcxNloXDTI2MDgwMTEwMjcxNlowFDESMBAG
A1UEAwwJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
03hn7w6VRXwgfD/AZSX479gmUjBi7KmWHLPXmFpDqxiwI+b8B+QkcX4i4CvHcytF
ows2VY3ahOt4mEXIuFmG4oKCRDmeFb4rWlzMC2psDb5rvlwHOCJz3e07/l/S2S+4
LbLmsCYO6ZpKqE/PTTkyyGZEAethnLEtg2UiPWhsi1CofLRTQwOqOlEWDydT7gfR
FQgX2uo8DcjRqcG3pIqzuaCYKfkVIu/8bQBF6Xqn16KBovBEi3pBs5KE5Z9g+gAY
yMG8BPqicmqxmVXc93NsrEbRnexbYAFZIIo5hbIytGMTT5NsufXu9jcLlRorxgtW
qQ3I/q7O4ax2iiLExU3uoQIDAQABo0IwQDAdBgNVHQ4EFgQUpCB1gxY2Rr4j7cuH
+WWLrwu6YqcwHwYDVR0jBBgwFoAUrfNsJlcLLxEv4L7NY8DgMb+0VMcwDQYJKoZI
hvcNAQELBQADggEBAJQ336ZKdRNo/QpPcmwzoqiO7qAdX2w5jhodzSbgmH5O2If7
UhkU4XQ0Q2GxndhsznWB3XAvq6minouzAi0C/oNuyydLfCjARNBYrZrp0h0X80R1
4Gf4OlKnSeTAWLPWCbE/hAIf3HWKxQnRX4Q/tIUg06ekfcL0FJ6I4WXcQ6jqn359
F4wL3sJoJqn20ntz/4Bcs/kwMmUi93NV1t1xSg5+I8akdd2A7tgRp9Dln0n51d3g
knSFMo7B64uc2xS2T3r4wCQadHocNqy7XHLQGGfV3xpw3m36e6cR1RpXqus2qpQh
EYD0qJ0UJsYYDIbocD+DAWqRJljSCvLVv+VwWec=
-----END CERTIFICATE-----
"""

private let clientKey = """
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQDTeGfvDpVFfCB8
P8BlJfjv2CZSMGLsqZYcs9eYWkOrGLAj5vwH5CRxfiLgK8dzK0WjCzZVjdqE63iY
Rci4WYbigoJEOZ4VvitaXMwLamwNvmu+XAc4InPd7Tv+X9LZL7gtsuawJg7pmkqo
T89NOTLIZkQB62GcsS2DZSI9aGyLUKh8tFNDA6o6URYPJ1PuB9EVCBfa6jwNyNGp
wbekirO5oJgp+RUi7/xtAEXpeqfXooGi8ESLekGzkoTln2D6ABjIwbwE+qJyarGZ
Vdz3c2ysRtGd7FtgAVkgijmFsjK0YxNPk2y59e72NwuVGivGC1apDcj+rs7hrHaK
IsTFTe6hAgMBAAECggEAH6xxJMUyZm3pD7Mcxgmh94qQcs78giYEbdgh+pfKet3/
w+Dc7vGk47rYzmrAPOfGTl1njfjpOe9q6KPLJJGEOnkBueZHX0pUg/xSM4OFG6nh
yWlPS4Ediaf2zGrd0dnr5CxfkRKiOSr686rAifh/OrTWitMOk8GV55BGSJxTZaox
UT/l73YHL/b83UCU7F1QqF+X4Dg1XGFFmhDcarHL+Jo5HhMLxM8DHgibWvzQ6tkK
QsgKUWp2wAPlyebpLIQn4GvBgBiIwOix95IHQo/sw7VZB9JiE3r9UCPsBtie2LHR
kNqcLdnYR3NgK3c5o2Wl5Qqrvw3u2/Tzha2X8zA0gQKBgQDyDIe9wVvrFjHtpVGV
JhEZb5XeRp2c7UU9K44TsTiX9IDR6lmNATzKBNtAlWrXyU9i+2APS9wv7Y8B2T2U
xUKCDHp0bCYYlSlBtuL6EPq82UOFno7+l6hHIkUkpf+wL5QdLruzKPwIhfMJNjRN
M3DZQfNAVGA5JafOLsik7SmoLQKBgQDfqK8BLk4RMEU2fYN8GKYNP5+zo1GxKK/C
g+AEClFPCFpbaulXhcYvWrHQ3cJOSpH+132BkofzCfYB9U8mCj900QwvS19C46+F
/k1coC5tzLLY5xLULggZAV4CcP9ZYfLJ0775Zdblx2GlWRJikp9BPpzpoythG68h
FxkXRQwUxQKBgGe92RwKWNQsgh/CAHJ1i1Skj85h48HTrB5ooY9tIL14LRJLaDBY
PG61oCdRIybzgFQDO4uyzt+36Ng4/PzbgwLsSDvH8pgMrk8dDLFzP5RbZmZJrC4Q
YC6E0K/BehJQgiHz2r0SLtuUVbM4CTiheJeVfaWvxEIaEo77XEHb6EPNAoGBAMwe
I5FdVCwFtLT1OaFw0WL39OU6IR0gt787IaAuVmRdiDE0Uj7pPKUNDYlEScev8Kv2
uHkfZOle5uCEo7Zg1ebjvk4PaKIgL5mHK81j9tuIXJTt1lZEqGlBwS1TOQe3B6BA
mmL8GXLdUvVXZBsIG0WtQgFMRBO880iszt5YypzNAoGBAN6TFm3zD/FFy7pvne/g
sD1sSj/rJRvNW18IXsD7u9/xCkaArtdEWGYu9P+lS4Cuqc8FFc8ieWVhN2QsNwni
5PeWMgmF4BcmQ+OhxHv6VfyZK4BZj4787P2cO9nJ4F7hK6B4JJUxLJY7pGTq7Tdj
7U6W35gWkL2XZN6A7An9VO3Z
-----END PRIVATE KEY-----
"""

private let serverExplicitCurveCert = """
-----BEGIN CERTIFICATE-----
MIICdTCCAhugAwIBAgIUY/hv1nIQiLTKWY5ITNJtrkdwfNAwCgYIKoZIzj0EAwIw
FjEUMBIGA1UEAwwLZXhhbXBsZS5jb20wHhcNMjUwODAxMTAyNzE2WhcNMjYwODAx
MTAyNzE2WjAWMRQwEgYDVQQDDAtleGFtcGxlLmNvbTCCAUswggEDBgcqhkjOPQIB
MIH3AgEBMCwGByqGSM49AQECIQD/////AAAAAQAAAAAAAAAAAAAAAP//////////
/////zBbBCD/////AAAAAQAAAAAAAAAAAAAAAP///////////////AQgWsY12Ko6
k+ez671VdpiGvGUdBrDMU7D2O848PifSYEsDFQDEnTYIhucEk2pmeOETnSa3gZ9+
kARBBGsX0fLhLEJH+Lzm5WOkQPJ3A32BLeszoPShOUXYmMKWT+NC4v4af5uO5+tK
fA+eFivOM1drMV7Oy7ZAaDe/UfUCIQD/////AAAAAP//////////vOb6racXnoTz
ucrC/GMlUQIBAQNCAASRzC2j8W3Lra4PJ+BgREUaznNdU2iBU3yWfnGsN+NIJxwa
zpeH5ju/AXqs6aYUufPOGK+PElaOEezHijkFePAOo1MwUTAdBgNVHQ4EFgQUqJu4
asijlp5iY2Wu6IBWO7BPuGAwHwYDVR0jBBgwFoAUqJu4asijlp5iY2Wu6IBWO7BP
uGAwDwYDVR0TAQH/BAUwAwEB/zAKBggqhkjOPQQDAgNIADBFAiAq4XXzzrlb1m75
yo6rA5bNu80EYKk40H8dRQBNxfcD0AIhANCVve6KRNGLHMzJFFFSa0s4y6W40ofr
2XT2FE+VskcC
-----END CERTIFICATE-----
"""

private let serverExplicitCurveKey = """
-----BEGIN EC PRIVATE KEY-----
MIIBaAIBAQQgm5kX7PEYxgXdhEdbrf7wdzi1RGbPfxNT2llcnRKQ0RKggfowgfcC
AQEwLAYHKoZIzj0BAQIhAP////8AAAABAAAAAAAAAAAAAAAA////////////////
MFsEIP////8AAAABAAAAAAAAAAAAAAAA///////////////8BCBaxjXYqjqT57Pr
vVV2mIa8ZR0GsMxTsPY7zjw+J9JgSwMVAMSdNgiG5wSTamZ44ROdJreBn36QBEEE
axfR8uEsQkf4vOblY6RA8ncDfYEt6zOg9KE5RdiYwpZP40Li/hp/m47n60p8D54W
K84zV2sxXs7LtkBoN79R9QIhAP////8AAAAA//////////+85vqtpxeehPO5ysL8
YyVRAgEBoUQDQgAEkcwto/Fty62uDyfgYERFGs5zXVNogVN8ln5xrDfjSCccGs6X
h+Y7vwF6rOmmFLnzzhivjxJWjhHsx4o5BXjwDg==
-----END EC PRIVATE KEY-----
"""

#endif // canImport(NIOSSL)
