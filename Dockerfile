# ================================
# Build Stage
# ================================
FROM vapor/swift:5.2 as build
WORKDIR /build

# Copy entire repo into container
# This copy the build folder to improve package resolve
COPY . .

# Resolve Swift dependencies
RUN swift package resolve

# Compile with optimizations
RUN swift build \
	--enable-test-discovery \
	-c release \
	-Xswiftc -g


# ================================
# Run image
# ================================
FROM vapor/ubuntu:18.04
WORKDIR /app

COPY --from=build /usr/lib/swift/ /usr/lib/swift/

COPY --from=build /build/.build/release /app
COPY .env /app

ENTRYPOINT ["./Run"]
CMD ["serve", "--env", "production", "--hostname", "0.0.0.0"]