test:
    cd example && \
    gren make src/Main.gren && node app

docs:
    gren make && \
    gren docs && \
    npx gren-packages
