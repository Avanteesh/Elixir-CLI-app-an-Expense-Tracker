FROM elixir:1.18.3


COPY /lib /lib 
COPY mix.exs mix.exs
COPY mix.lock mix.lock

CMD ["mix", "compile"]
CMD ["iex", "-S", "mix"]


