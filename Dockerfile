FROM dart:stable

WORKDIR /app

COPY pubspec.* ./
RUN dart pub get

COPY . .

RUN dart compile exe bin/api_biblioteca_pessoal.dart -o bin/server

CMD ["bin/server"]
