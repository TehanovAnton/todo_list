# Используем официальный образ Ruby в качестве базового
FROM ruby:3.3.6-bullseye

RUN apt-get update -qq && apt-get install -y libpq-dev

# Устанавливаем рабочую директорию внутри контейнера
WORKDIR /myapp

# Копируем Gemfile и Gemfile.lock для установки гемов
COPY Gemfile Gemfile.lock ./

# Устанавливаем зависимости с Bundler
RUN bundle install

# Копируем остальную часть приложения
COPY . .

# Указываем, какой порт будет слушать приложение
EXPOSE 3000

# Запускаем Rails-сервер
CMD ["rails", "server", "-b", "0.0.0.0"]