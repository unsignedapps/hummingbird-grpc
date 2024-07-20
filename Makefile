
# Regenerates the test proto files in Tests/CompatibilityTests/Echo/
# Assumes you have `protoc` installed in your $PATH. You can get it from `brew`.
test-protos:
	swift package resolve
	swift build --package-path .build/checkouts/grpc-swift --product protoc-gen-grpc-swift -c release 
	swift build --package-path .build/checkouts/swift-protobuf --product protoc-gen-swift -c release
	protoc \
		--plugin=.build/checkouts/grpc-swift/.build/release/protoc-gen-grpc-swift \
		--plugin=.build/checkouts/swift-protobuf/.build/release/protoc-gen-swift \
		--grpc-swift_out=Tests/CompatibilityTests/Echo/ \
		--swift_out=Tests/CompatibilityTests/Echo/ \
		--grpc-swift_opt=FileNaming=DropPath,Visibility=Public \
		--swift_opt=FileNaming=DropPath,Visibility=Public \
		.build/checkouts/grpc-swift/Protos/examples/echo/echo.proto

sample-certificates:
	scripts/make-sample-certs.py
