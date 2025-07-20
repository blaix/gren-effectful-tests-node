test:
    cd example && \
    gren run Main

docs:
    gren make && \
    gren docs && \
    npx gren-packages
