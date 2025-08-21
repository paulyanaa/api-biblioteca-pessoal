# Usando imagem oficial do Dart
FROM dart:stable

WORKDIR /app

# Copia pubspec e instala dependências
COPY pubspec.* ./
RUN dart pub get

# Copia o restante do código
COPY . .

# Compila o executável
RUN dart compile exe bin/api_biblioteca_pessoal.dart -o bin/server

# Comando de start
CMD ["bin/server"]
