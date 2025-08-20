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
    notAfter: Date(timeIntervalSince1970: 1786016948)
  )

  public static let otherCA = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(otherCACert.utf8), format: .pem),
    commonName: "some-other-ca",
    notAfter: Date(timeIntervalSince1970: 1786016948)
  )

  public static let server = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(serverCert.utf8), format: .pem),
    commonName: "localhost",
    notAfter: Date(timeIntervalSince1970: 1786016948)
  )

  public static let exampleServer = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(exampleServerCert.utf8), format: .pem),
    commonName: "example.com",
    notAfter: Date(timeIntervalSince1970: 1786016948)
  )

  public static let serverSignedByOtherCA = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(serverSignedByOtherCACert.utf8), format: .pem),
    commonName: "localhost",
    notAfter: Date(timeIntervalSince1970: 1786016948)
  )

  public static let client = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(clientCert.utf8), format: .pem),
    commonName: "localhost",
    notAfter: Date(timeIntervalSince1970: 1786016948)
  )

  public static let clientSignedByOtherCA = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(clientSignedByOtherCACert.utf8), format: .pem),
    commonName: "localhost",
    notAfter: Date(timeIntervalSince1970: 1786016948)
  )

  public static let exampleServerWithExplicitCurve = SampleCertificate(
    certificate: try! NIOSSLCertificate(bytes: .init(serverExplicitCurveCert.utf8), format: .pem),
    commonName: "localhost",
    notAfter: Date(timeIntervalSince1970: 1786016948)
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
MIIDBTCCAe2gAwIBAgIUdQ3kGOdAaoDrdYslrk9bvDTX6eQwDQYJKoZIhvcNAQEL
BQAwEjEQMA4GA1UEAwwHc29tZS1jYTAeFw0yNTA4MDYxMTQ5MDlaFw0yNjA4MDYx
MTQ5MDlaMBIxEDAOBgNVBAMMB3NvbWUtY2EwggEiMA0GCSqGSIb3DQEBAQUAA4IB
DwAwggEKAoIBAQCbOqAbjOGTJmiGq0gA30kCtOMF0cZUm4ijSPDjfb8rG5Rnn2JA
lcm/XRbnj5nffjORf0ZamnZTPwOoS0JrRyZMAjhIumazW0OM4dQkNced1ilQbnkv
KYo/jA5z19i3tJosiCiE57/+sOz3XPkBAbWZKnep4OY8RPTFvUObMPIqCNZzlXvh
pwaz+DBUW4RMdOBb9NyXDOFk7tVneBKQaQiWkyre5KCznBlbpOpLvrQO/2iRoxIT
LVXGdDzcNzOW0iVtuuzoHf2+21IzLnpZei7u93ed6CfrujKJmZiaPhbbXRscdylZ
gkgsU8omano914rMLEd2kGd8cTbIlaxuFaztAgMBAAGjUzBRMB0GA1UdDgQWBBRr
2SPcmeIWl/tUyQrqj9agNrsZbTAfBgNVHSMEGDAWgBRr2SPcmeIWl/tUyQrqj9ag
NrsZbTAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUAA4IBAQCZLBRQ5m0u
6TpdbFCm06v8QXX/3GCR5rpVNumm9Am7U7pwUlUe+xminz8yOm9U7tMWiAH6sZ68
vK1uZbLsMEmwUWi26avXLQ7zMR9o7RuDtxfcWUHy6MeydGaSQ6eVAbLOgY4SLikr
7sA/voqDvIhOE7Jm1900+ohOblxSn0/2bBkpb7slTKhrNh3xKwSyfBypF5ZlWXmh
ejVVRefhAzFlUC1tLGn03WnWcY6gWi6sGxQcT7TiKd8XqXstbqy4cQ5vw3ZrD+v/
3d4RZPPTidjG36i9uZOoEt3C1UF2EzgbzwqUuPEvxN6L6v68eKNnvSF/PCOqDr9H
K6+bKA0LzKBA
-----END CERTIFICATE-----
"""

private let otherCACert = """
-----BEGIN CERTIFICATE-----
MIIDETCCAfmgAwIBAgIULph+Qk2RaiSAeBGCVXw0d+nUW54wDQYJKoZIhvcNAQEL
BQAwGDEWMBQGA1UEAwwNc29tZS1vdGhlci1jYTAeFw0yNTA4MDYxMTQ5MDlaFw0y
NjA4MDYxMTQ5MDlaMBgxFjAUBgNVBAMMDXNvbWUtb3RoZXItY2EwggEiMA0GCSqG
SIb3DQEBAQUAA4IBDwAwggEKAoIBAQC5unU/PRQmXkaYKSeG5GirtjQ2xx8Fj3Wh
qNTqAZQD6LtuA2ORItRhybKzembP5Jde02pvflzANgrSIcCxcuUeLLKVAOj4fjUh
RxL2Ws16ozxLzB/gsDyS2ovLE9SwLS3KNYgvkinvPnD1Ua31wcH9tcA/w3NWS+au
8QA8fgHKUnUmeMqavwAhaFU4q+RuMXNsF6H3gN3WnoOwW9KWFkkOQJJNe+VYOz65
qEB+3eIq6cdv1MYM2hLD3beEqpgD0xkDBfIqCA0AMsTsEM6rMcZi1D3Kh40y6rAS
E8vdfy/AqvinBkao7mws1W9NcQfncvW0aCAz58zwCTgilkCdij8FAgMBAAGjUzBR
MB0GA1UdDgQWBBTM8dQ9pc/YWE6rjjCrcJk3vEn2nzAfBgNVHSMEGDAWgBTM8dQ9
pc/YWE6rjjCrcJk3vEn2nzAPBgNVHRMBAf8EBTADAQH/MA0GCSqGSIb3DQEBCwUA
A4IBAQA/V/FL7g9T4M4UPnz3r9oaDXWgOM4DiT3Egc6eF6iKODDbvy0CdMnGIf7p
OpGmb3nAUCRsqthZaEKVHmh4UoC4Iew0M4Y//QwraF0GklviyI6BYjvpa5elsA3y
64QFWb4dbktIl8qxYlaktDQIM4e5BlC9eX7t1+5KSYNrlzO4o0iamRkkvYMn92W7
O7YHGTzM2uNWn567h/wobPwAn4PFNKH1uhLpaAFcorqgaNb05LdEWcrNuRYnRlMd
Py4u0/eGWxGtbTfLzDgIV/PkzqNtJQD6YNSNVInr/IqmLjXm8xC99MhoXaS0k4nU
McmCkJRlHR8RsuJIqTq4NdK8G2sE
-----END CERTIFICATE-----
"""

private let serverCert = """
-----BEGIN CERTIFICATE-----
MIIC4zCCAcugAwIBAgIBATANBgkqhkiG9w0BAQsFADASMRAwDgYDVQQDDAdzb21l
LWNhMB4XDTI1MDgwNjExNDkwOVoXDTI2MDgwNjExNDkwOVowFDESMBAGA1UEAwwJ
bG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAp2BnkgbT
SlfaN1o4zXJJkP3MJq8w0mBAccWZosfeZoZTiK3xDaAyU4nvNb2S8RGUSS/kezOi
bdulWk4emPSh9mtZQDfDosRk5BE016zg9e+G712eQlZ89UYgehmbCv9E70Hq5T3m
PAbOsI6bHP4flDb2aSPlEhxIPE6/6e+VKt/X1Fi8h8MjpNALbNSJ/RuAqsdR4zMm
d2cZ4neYn0K3eUlsFVEHeEpBhuTb53+pLoqtjFlWM1qp1cUobWGPonKcH6JcAbSt
yDZY1GBzsf0u8lBeIdT32feUD3Scyk98LPiucWZZAB9CiF0Ttto2WWOVrgGRMzCC
dO9MJMuTKJbciwIDAQABo0IwQDAdBgNVHQ4EFgQU8Rq4FtEfESJVowJN9hLpLS6g
YL4wHwYDVR0jBBgwFoAUa9kj3JniFpf7VMkK6o/WoDa7GW0wDQYJKoZIhvcNAQEL
BQADggEBAEtYGz2R19vgjLwKiX6uD8NJPJ4in5TNjR4nMmBNTRaPC3e7zevbIfOb
FmU6vzYPTfqRsOHdygiqiH6qPTyAV2QiXAd/09KF6XpJART3kbYktamVAIj5bUwO
AB7BPMT/f6XUEAgFp/jrO2GP7guiSL2WM2VCzddEbJM4WwqlKBDqjcmdAwwCBDUU
B6UMQSCQ2mVsmKfiuXz6v5wD7U38ql2UDJBBdMeM2bttRmd+i7MeZYA8QQJApCgB
iN1njTqPEyR1c8UhNN3CTFYR5hiko2NIN5NQ8XutVdvUH/oSI402hH5U0vz6T/RZ
4WahCfK6xVHghw/TCiqsVkWIfnmA0TQ=
-----END CERTIFICATE-----
"""

private let serverSignedByOtherCACert = """
-----BEGIN CERTIFICATE-----
MIIC6TCCAdGgAwIBAgIBATANBgkqhkiG9w0BAQsFADAYMRYwFAYDVQQDDA1zb21l
LW90aGVyLWNhMB4XDTI1MDgwNjExNDkwOVoXDTI2MDgwNjExNDkwOVowFDESMBAG
A1UEAwwJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
p2BnkgbTSlfaN1o4zXJJkP3MJq8w0mBAccWZosfeZoZTiK3xDaAyU4nvNb2S8RGU
SS/kezOibdulWk4emPSh9mtZQDfDosRk5BE016zg9e+G712eQlZ89UYgehmbCv9E
70Hq5T3mPAbOsI6bHP4flDb2aSPlEhxIPE6/6e+VKt/X1Fi8h8MjpNALbNSJ/RuA
qsdR4zMmd2cZ4neYn0K3eUlsFVEHeEpBhuTb53+pLoqtjFlWM1qp1cUobWGPonKc
H6JcAbStyDZY1GBzsf0u8lBeIdT32feUD3Scyk98LPiucWZZAB9CiF0Ttto2WWOV
rgGRMzCCdO9MJMuTKJbciwIDAQABo0IwQDAdBgNVHQ4EFgQU8Rq4FtEfESJVowJN
9hLpLS6gYL4wHwYDVR0jBBgwFoAUzPHUPaXP2FhOq44wq3CZN7xJ9p8wDQYJKoZI
hvcNAQELBQADggEBADjBpTdBh/0oqt2b1uaq4EsdjBsQ4nSvkGQAJmNSCpoResf2
R9dHMaDns03j1qJYjM2CEC33MEwG16VREw5DKl5ajE8Mk+ITI1n7IZI94Ih8NLqy
vxo5dicspY6kcXxDHkJb8/Vnztg3uLAGTfqKNabfB1kPlkdgvXNuNO3gL3/UE50U
auQqDQ4a3Acr2pJtHNuJRzqo6xKpV6JpyrsIWVBzr9CYm+jAGlumZRJ4j+DLe+o9
GrFkCkjXsq34WAwa8Hv0r32ahorvRW6OwIiZcgVandB+hMPju8AdQEyKXIja4sA4
pwtMFw8xD3T/5HCudds2eCmCjJRP1Z++akAJZt4=
-----END CERTIFICATE-----
"""

private let serverKey = """
-----BEGIN PRIVATE KEY-----
MIIEvgIBADANBgkqhkiG9w0BAQEFAASCBKgwggSkAgEAAoIBAQCnYGeSBtNKV9o3
WjjNckmQ/cwmrzDSYEBxxZmix95mhlOIrfENoDJTie81vZLxEZRJL+R7M6Jt26Va
Th6Y9KH2a1lAN8OixGTkETTXrOD174bvXZ5CVnz1RiB6GZsK/0TvQerlPeY8Bs6w
jpsc/h+UNvZpI+USHEg8Tr/p75Uq39fUWLyHwyOk0Ats1In9G4Cqx1HjMyZ3Zxni
d5ifQrd5SWwVUQd4SkGG5Nvnf6kuiq2MWVYzWqnVxShtYY+icpwfolwBtK3INljU
YHOx/S7yUF4h1PfZ95QPdJzKT3ws+K5xZlkAH0KIXRO22jZZY5WuAZEzMIJ070wk
y5MoltyLAgMBAAECggEAMwHKDlJOKaXENoIkNVfS24C8qj1RX4s9mG5jd5v5Rr1A
z7JSd5iOPa8XWwU+toBo9DTIKFN/+IKrTW3pHSvP/8yPEmbsE7pOFMK5m9BvbgNk
16VsCUNaKVUJqKwM97j7RP6NmvbWJwzcCCotUxSOgxiM11W9BVvhF5/YFG6SwtGe
DBGSSw0K34Z06Jhyy5rdh8y93PQsGZTUEfdWdRh5vLvGIAxZ8RooZWPT9okJUPAJ
IbAJadZm/wU870s271ZRlYjc4lOz/Ucl5d7+E7r7Ac5uM+eUwqKGEg9z7iglyDYg
X4P0TZcowiU0MWSYgjTGD0iCPTmWGLcrbpYum/3HwQKBgQDbzBNxm5mZ1u5OJUaS
k0Y+ogClx8AqhXer/x8e+fJvitQeGamR/0uu4zv7wRUhRqtLO0jHGE2s4g4/UAwv
Zr4Sdzd0r/kVJIO9ohG5E3mCtim35m74eVN9RKxaL3+2Eat0d4MAK5HfFUdEUOUT
h56JgeJMXeo8rxXanhfePyKRIwKBgQDC8fjrMKt80z+PqOb7aXPt9zZFB3p00knn
HCmOWp/Rh4lQs+Sm4Ueqy0o15b/mehUXIVDQZuJRvL+GW7q2Luwn4m0GqB5DxaaR
Y/p9d+Sk13xtSljP7DZBfnhnjRHdLKH4ooRKm7Ljqd6cmx3FKUYyoB4E0t3xc9l+
KvTBV9ZheQKBgQCkL0Za9+t+QlIS579W4FJ5mNQ5AgRm/voM7e8WWYkijyayMWM8
nuKvCikVfv7Es6Bi+y77Iglr2hTgcHAZvHrBGnK/ZHAAvhz2u6jXglejL2XsbGJ6
k06tZW4FlDOnEn3r6xZdOy6k4KUyv+bOduETQIWFnCXMHNGLU8rqhmjQ1wKBgDfA
qjbhMXo+lEQKwxyN+SjKdcviKqR0a8xb4oqi4mgzQhNBj5gmf6+Z+jxV278XlSaL
Uah4dCt6NrA/VbO60bFKcXHg7N7nDQ8xr7bobgyy0BQVmjbE0HOErvy2fLBrjlsk
Z39K7itsLo1NU4NKnZfm8Q7iG7VtM3uA34TYESjJAoGBANDvf0QANISS5RwNG5r/
t3TpUpuyGOa5xsXp1RKX1WeJPj4QPk5vLKdRtXJtvXP6WsaZ/3hpGxstiAFyWAjO
+vmryywc4mJkBML/8aq0smKPIKCdYsSn0NFgyK9mSQxiIV1CZnhuiwqod9N0PZ6s
+BjJQJ1YeQzza3micrl0Haq+
-----END PRIVATE KEY-----
"""

private let exampleServerCert = """
-----BEGIN CERTIFICATE-----
MIIC5TCCAc2gAwIBAgIBATANBgkqhkiG9w0BAQsFADASMRAwDgYDVQQDDAdzb21l
LWNhMB4XDTI1MDgwNjExNDkwOVoXDTI2MDgwNjExNDkwOVowFjEUMBIGA1UEAwwL
ZXhhbXBsZS5jb20wggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDtITEM
/SuLOSM6V6I0a/xWozZgnZ+i13Ca9Vzgl3AqKjlhSPaL+233GWpkrR7c2qQT/T3d
TsqGoS3qXUYDK01AqTvxM9Ha3dSitDKLrbCi/mL6Q8H+DZOk+1H1APwkq6QWVA0v
PK4Cdw+VLlwcwl+gsT9ijYlZnEc70woxWtCBoQF9qma0+NqCUfeRKE3b0yRjb2V8
1igCxLBnGR7v4qDem0XDO8L7kdX1QSpSUY9/PwNfSOeXu0yVHq90t2AS9Ykr66+f
e+qxG4irPbfuSfbAvIwkmGlmWertsxO/Ht3VEjg6dwNsLFCFDppLTatIoHjeprVi
PvQGpuuRIMLZ+b6RAgMBAAGjQjBAMB0GA1UdDgQWBBSrUC9SOYXX5nIUN8nNNVcL
B4N10TAfBgNVHSMEGDAWgBRr2SPcmeIWl/tUyQrqj9agNrsZbTANBgkqhkiG9w0B
AQsFAAOCAQEAQPZskS8ddprozwdHkpc0lFBWo60PM2CFyGQBlHoQo4AzPG3kmL1r
oCT1tU9LLod/zuCpzjdB/1Qe8eKi6xOEPdNiAfs2b4qQYdbzBlRAVxFQCcU1p/7p
0rcM8ER3CILgu0lgiwQGQQ/WYmvNbol6T0kAdpTL/2adlzF07noqMHqeqJq40ue2
N2OlFRyZ40zrM7WjLSD/oYSNcMUjeCqxZtisq/N8p5k1YD49NgXioHcNYdoTja7f
tBTGojCR17a4593lfJ7j3ebk4pRA1FIedR7FkXmJ7roSUShPQf9cwVUjzPQ6EZ5S
ZY1cMmbIjTwk0YUykc1LFL3qdBqCzxRa2g==
-----END CERTIFICATE-----
"""

private let exampleServerKey = """
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQDtITEM/SuLOSM6
V6I0a/xWozZgnZ+i13Ca9Vzgl3AqKjlhSPaL+233GWpkrR7c2qQT/T3dTsqGoS3q
XUYDK01AqTvxM9Ha3dSitDKLrbCi/mL6Q8H+DZOk+1H1APwkq6QWVA0vPK4Cdw+V
Llwcwl+gsT9ijYlZnEc70woxWtCBoQF9qma0+NqCUfeRKE3b0yRjb2V81igCxLBn
GR7v4qDem0XDO8L7kdX1QSpSUY9/PwNfSOeXu0yVHq90t2AS9Ykr66+fe+qxG4ir
PbfuSfbAvIwkmGlmWertsxO/Ht3VEjg6dwNsLFCFDppLTatIoHjeprViPvQGpuuR
IMLZ+b6RAgMBAAECggEAGoz+2v914q7RHPU2+julE2ZO7l53w1nwB8m1TohmTLJR
nmz2/hF27JXx7bfcnsn0WTCfvqnVz2E4rOcosa4lhjnstkMhGiqAZn9asX0PLBDj
sDXqALIwd+aT9KTZlpmJU96xYzqeGTSPkBqSwb2Zy3pNKJHEcT4oU7B7ka8jbYAM
ZDehUFuwzq9LHyIWfu/P55ZCVgxFFstLazV0RMb46GvaHpOUv08jZi65RnpTBfNF
iBG1TIpYlPV8cifmeUHbi2tdEokYKL99KGWTrHoAqEpwpZw9edg6qZxERd4CNr7u
FR0LWKjcObssNKV6eQYfMP6CFSiAIIFNz8vagOcmgQKBgQD8GzgcNFiFU0i6dIZV
k9sYJco6f5eOG0N4cjfCY1pZUyt7XQjQgbDkmI78laAX7YA1CYdyxovRMnl6qMP9
JwdzzaiTOgLrQkpUmhKKaom0GkgpNHO8dgmE2yfAfxuzcTxFeW9IAnCJhHFk2/Cv
jJQK7mv+98mJdyNejzkcfyyLqQKBgQDwysHrVNfU/wc41zxAq6o4f5Ng2AiyN97q
1scBWLeG/X2EZrKoIs4URc5RAC2uip49XjmPHPjhNaONa//seaEGdjuO5g9WBxNs
B5WCtOIPoqYIXrQpjT7eKKFO2YE+dWD6f1VxrCaj0NcNq5bJaP88FLtEoF+aHHoM
7yW871ysqQKBgQCfsfZHF3mDaxBE3A9EIlbE4xtJFw2/vNFueJuNjTXsI10F1hcB
TUXqaCEbKwSwY4e1EQY11EM5DwoYgtMzhweXeYzxRewXbnR7RuW7vGTiK0vOniU6
GmNJPzHdJCc98drF/3hYWwNCeR0DULcT3K7ihcjvR7LoWwmSmpMI1B45kQKBgCIA
H13BfzB+SmDGU6W2F7UenorgNmoj5YA3j6YrBs8y4BRgA/4l2/+U08swQUMSI8H6
mhoRNztlvZBsnZignBIzg7lr1uKI4T8x2vS34evfRZ6M8NelMClih1SA9fUB0g3N
CR2h91rOVG+DuSj7gH7VVpQcKSOzvbAx3JxPGEDxAoGALyASIxB93QVEIXyPOt1u
zKXU3wbo5FrD+Pni47ijX2ioUrkFWPEwhe+74MkKsrarvPecJ8juHvqIDWgxJDuy
UOmEjmdYS8Ap4Hf+i5FcLr4/S5mDfX73lOVhIADCfNra0sF+sHJIj5Di+Dd9kBT4
+qGG9cjYHVIC0zsa2oid76U=
-----END PRIVATE KEY-----
"""

private let clientCert = """
-----BEGIN CERTIFICATE-----
MIIC4zCCAcugAwIBAgIBATANBgkqhkiG9w0BAQsFADASMRAwDgYDVQQDDAdzb21l
LWNhMB4XDTI1MDgwNjExNDkwOVoXDTI2MDgwNjExNDkwOVowFDESMBAGA1UEAwwJ
bG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEArEXUxSRf
JIIF6O4YE9YBD/mHqXHNQA+fvyWXcWzXr87iG5mNcOTtDg174r9458CAq7RLOf+3
us+LSbaXUcpFfsi++MtjjfWIT4CyD0IfsKT6NL3BxQ0V0IueVm6XESQXTZNvXx+U
anOh4nivSeaV1hkpBXIfRiOxXkgdngwXOVCFVwV/eFymOACIUfr1L6DUXPPEYcRe
sKzqHh3+eTTqrV858VRtBMgq6PX5Qewi+hNlQ92vzusZdYoBQ/28XgT8bew9OpAe
vMTZmpXEKIDvSyNZtgF6NjdQq/iZYvkHL1nVXlDSh1mlKoIxIHEvpWuGIV/TXzFt
OM2nKDr9EQHwzQIDAQABo0IwQDAdBgNVHQ4EFgQU5zYT5ALNdeW11TkDz4pW0lv2
fzYwHwYDVR0jBBgwFoAUa9kj3JniFpf7VMkK6o/WoDa7GW0wDQYJKoZIhvcNAQEL
BQADggEBACb9fmSGVzftOOPjFxbZIyvYxeebgenrN5hjNIeGeirppxQlYxbknsh9
QWqfRRELmwqFKG/dRcYOZMaRo7MX6INQWkMQOPe5VNlM8+qLi34dyL9JeHGc2FL/
3ic9bWiO32u/WEPVz1u39SDlHMb7VOtLsS5Tp4H8rZoD6rzMDfFOND27Ytzyq972
hhz2iuxGheJqJZNQL8PKMNpcmCQSmgdmk+7SlJ8tCQb4BDZeSfAjV+Z8reTpozXt
vEvcae1AyTogBvtAdS76m8BS2D/poRL6Lkbx/sbb8yVc0zIhsSEeKhIt3b2Re+V5
lm6lrFwX2KF/DjT0r0xBeXE46uYEGIQ=
-----END CERTIFICATE-----
"""

private let clientSignedByOtherCACert = """
-----BEGIN CERTIFICATE-----
MIIC6TCCAdGgAwIBAgIBATANBgkqhkiG9w0BAQsFADAYMRYwFAYDVQQDDA1zb21l
LW90aGVyLWNhMB4XDTI1MDgwNjExNDkwOVoXDTI2MDgwNjExNDkwOVowFDESMBAG
A1UEAwwJbG9jYWxob3N0MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA
rEXUxSRfJIIF6O4YE9YBD/mHqXHNQA+fvyWXcWzXr87iG5mNcOTtDg174r9458CA
q7RLOf+3us+LSbaXUcpFfsi++MtjjfWIT4CyD0IfsKT6NL3BxQ0V0IueVm6XESQX
TZNvXx+UanOh4nivSeaV1hkpBXIfRiOxXkgdngwXOVCFVwV/eFymOACIUfr1L6DU
XPPEYcResKzqHh3+eTTqrV858VRtBMgq6PX5Qewi+hNlQ92vzusZdYoBQ/28XgT8
bew9OpAevMTZmpXEKIDvSyNZtgF6NjdQq/iZYvkHL1nVXlDSh1mlKoIxIHEvpWuG
IV/TXzFtOM2nKDr9EQHwzQIDAQABo0IwQDAdBgNVHQ4EFgQU5zYT5ALNdeW11TkD
z4pW0lv2fzYwHwYDVR0jBBgwFoAUzPHUPaXP2FhOq44wq3CZN7xJ9p8wDQYJKoZI
hvcNAQELBQADggEBAIjQYLowGowcVjTbXVm1GfKblM4DwqKc4k/6ZtdlCxpf4qHK
OTP6WarGTxuJ1knL0wTC0Wh3VEw83ZoRrl9RbgoDesMbDn4mS6DbTh28FYbS/P87
EoX6HJydctb7STozEI1okeBGbR3TJiEMPFqUcAELtfWxx4F1HkInQurnBROUKgLX
lmBBHCuWm7AeeI2bXEU5yhIMFKLdJXu5kZALCg1XADrjNGq5rxpRwXQ+SmYpdamI
1qycvIRAudwgg22cmrfbOxGHYuR7Fx/GZR0Ev/oz+r0b+sW3y8eZww6goYnBkHb8
yzhOpbHpxlq62DT2y2wu8Tf3oHHZo9rjFB9rof4=
-----END CERTIFICATE-----
"""

private let clientKey = """
-----BEGIN PRIVATE KEY-----
MIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQCsRdTFJF8kggXo
7hgT1gEP+Yepcc1AD5+/JZdxbNevzuIbmY1w5O0ODXviv3jnwICrtEs5/7e6z4tJ
tpdRykV+yL74y2ON9YhPgLIPQh+wpPo0vcHFDRXQi55WbpcRJBdNk29fH5Rqc6Hi
eK9J5pXWGSkFch9GI7FeSB2eDBc5UIVXBX94XKY4AIhR+vUvoNRc88RhxF6wrOoe
Hf55NOqtXznxVG0EyCro9flB7CL6E2VD3a/O6xl1igFD/bxeBPxt7D06kB68xNma
lcQogO9LI1m2AXo2N1Cr+Jli+QcvWdVeUNKHWaUqgjEgcS+la4YhX9NfMW04zaco
Ov0RAfDNAgMBAAECggEAALRKC01GWKFHHL2TxR79QvS08IUkful2xc1a9Lh/xY+j
CSmunu0cp/pM95oV8zKXBBIDswwVKEhuwWwjlblt4SJjyiNrYoTusU6Cy9ZWx/4r
VK8IPVc779iQ8DmvAz+tGwt/gM7MU0a/kmwGYWxgepnV5a24AYLQrTnpFGs9vBBT
EjQgRwpvg31TaHrvxjVuvmEInCebq3LuVe+hYQJN/ReeK348xcv4XWw/C3/AX6fb
dYsVVNUW+CA8+DJL0l17kbkT9RJTfGDUwh1oLt8mu4nhAjsQFiS+rdJ9SDr0rCJM
ln+wQnAnpwLlnaNawGNicotZbD87xlf3xQkBsrnV6QKBgQDXFR+4jT6B0t+fHdKb
lwSi6GljjgLj7b4qYdBM31O728SZYNdbE096ea6J5mJkTPzOzsL1KveRSma/F1rJ
C7YjQsZ/kOJ/V6wtePJ0pd6inTyWy9mXJLz8UBedsqFAnJYzAzWF28KcjI2uIVzz
S4ZI9guMAkCsPKXZmy21HTRVJQKBgQDNC81FIGxdAGUW74IqKLI3NYeaDt6NQo7E
ANCeHlzEDuT8qokUI+HNH3dmrsiIYTjgcjJ/eoqI1p1k9D7sAD2NaAA5QoeV9oKv
NXdj8m3ONbe8hPYiu1LYUOOC2Cr1jAXpGSaE2GwHQ4gZDzEqhY9mKlQ7Ai0CrthO
ix2e14DgiQKBgAPcBS2ymySJPCoGxvizxQmHUhzPN44PfhIUn0BB4abFUsnNyw9/
UTXJaTBgSfOyzfaID0eG9dpNk3pqWN6yrxoC4Lz5RJc0Y4qNWQxuzYftemDaV5U2
u41rgoD565rVNHzF2fgE8YENpJ0zTA+xkz9L6vkgMTjl/bPh7PgLBh1hAoGAP+qW
4R57SP5PhLfCPnwTGayhCX/rFeOSdzy9yxwx1JfD/5L1SgbpYzSU1rhTIFgWD7jp
Tt2XA5LK22Zbmtt0VHj/4NmBRFjkYdNr1QcD/Yy3KpfT1f3IlE+aq/XQZlxwlznU
zQJdomIFsbIPpG6fxbwaJ47FExoHqWwqHpKUxOkCgYB6inRznM2+TnATirHXbjlF
ReSKzsLAdisyMpv0zaD8ulmw7XwI7ah7g4UcR+LzoiWTmqlIBhj5IryCiyTsrbe7
oH2lKPHsTvDCk+r2TBWHBjQDUMQ2rLg6XNHArzQqyCbKHnarJCVNaS2Jg7M+v7RN
LNOgs36nq1MXZF9XNhAOhA==
-----END PRIVATE KEY-----
"""

private let serverExplicitCurveCert = """
-----BEGIN CERTIFICATE-----
MIICdjCCAhugAwIBAgIUHp8G+r0KsIH1988Wv6mcEnTPtqkwCgYIKoZIzj0EAwIw
FjEUMBIGA1UEAwwLZXhhbXBsZS5jb20wHhcNMjUwODA2MTE0OTA5WhcNMjYwODA2
MTE0OTA5WjAWMRQwEgYDVQQDDAtleGFtcGxlLmNvbTCCAUswggEDBgcqhkjOPQIB
MIH3AgEBMCwGByqGSM49AQECIQD/////AAAAAQAAAAAAAAAAAAAAAP//////////
/////zBbBCD/////AAAAAQAAAAAAAAAAAAAAAP///////////////AQgWsY12Ko6
k+ez671VdpiGvGUdBrDMU7D2O848PifSYEsDFQDEnTYIhucEk2pmeOETnSa3gZ9+
kARBBGsX0fLhLEJH+Lzm5WOkQPJ3A32BLeszoPShOUXYmMKWT+NC4v4af5uO5+tK
fA+eFivOM1drMV7Oy7ZAaDe/UfUCIQD/////AAAAAP//////////vOb6racXnoTz
ucrC/GMlUQIBAQNCAATWSNjoeHPGdTJ3J/hN/rjHaGyMik5d0/TswENmxXVkRM2U
tSxNk+zVGtumhlFGs+5lzzbvdS+9bkrWRxfxLak0o1MwUTAdBgNVHQ4EFgQUQawO
L7qhYBwK/9Vb3ROsy/WPTs8wHwYDVR0jBBgwFoAUQawOL7qhYBwK/9Vb3ROsy/WP
Ts8wDwYDVR0TAQH/BAUwAwEB/zAKBggqhkjOPQQDAgNJADBGAiEAm1qzfSkwW/YH
j+HzmrYz+LxUFent5XvhHcmZ0O3t3joCIQCfojRwycgn8xEkR+Cz1KSqrKVts9na
7q/ACYbNh6S0xQ==
-----END CERTIFICATE-----
"""

private let serverExplicitCurveKey = """
-----BEGIN EC PRIVATE KEY-----
MIIBaAIBAQQgJYcG1DfYvwgZOH679tx+TCses0SQRQt4vu18rKm2uDaggfowgfcC
AQEwLAYHKoZIzj0BAQIhAP////8AAAABAAAAAAAAAAAAAAAA////////////////
MFsEIP////8AAAABAAAAAAAAAAAAAAAA///////////////8BCBaxjXYqjqT57Pr
vVV2mIa8ZR0GsMxTsPY7zjw+J9JgSwMVAMSdNgiG5wSTamZ44ROdJreBn36QBEEE
axfR8uEsQkf4vOblY6RA8ncDfYEt6zOg9KE5RdiYwpZP40Li/hp/m47n60p8D54W
K84zV2sxXs7LtkBoN79R9QIhAP////8AAAAA//////////+85vqtpxeehPO5ysL8
YyVRAgEBoUQDQgAE1kjY6HhzxnUydyf4Tf64x2hsjIpOXdP07MBDZsV1ZETNlLUs
TZPs1RrbpoZRRrPuZc8273UvvW5K1kcX8S2pNA==
-----END EC PRIVATE KEY-----
"""

#endif // canImport(NIOSSL)
