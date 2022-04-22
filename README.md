# SimpleGame

This is a companion Swift package to [Narratore](https://github.com/broomburgo/Narratore), and its purpose is to show some examples of its usage.

You can try out the example story by running the `SimpleGame` executable target.

Please refer to the main `Narratore` [README](https://github.com/broomburgo/Narratore/blob/main/README.md) for a more in-depth description of the content of this package.

## Using this code in your projects

The main purpose of this Swift package is to document `Narratore` features. Nevertheless, most of the code can be used in your project, in order to start playing around with `Narratore` with minimal setup. In particular, 3 targets of this package can be incorporated in your projects:

- [SimpleHandler](https://github.com/broomburgo/SimpleGame/blob/main/Sources/SimpleHandler/SimpleHandler.swift): contains a generic implementation of the `Handler` protocol, that allows to running a story in the command line, and persists the state of the game in a `.json` file, while also providing a function to restore the persisted state, if available (check out the [SimpleGame](https://github.com/broomburgo/SimpleGame/blob/main/Sources/SimpleGame/SimpleGame.swift) executable implementation for an example of `SimpleHandler` usage);
- [SimpleSetting](https://github.com/broomburgo/SimpleGame/blob/main/Sources/SimpleSetting/SimpleSetting.swift): a pretty basic, but flexible, generic setting for a `Narratore` story;
- [AdvancedSetting](https://github.com/broomburgo/SimpleGame/blob/main/Sources/AdvancedSetting/AdvancedSetting.swift): based on `SimpleSetting`, enhances it with a more sophisticated `World` definition, and a localizable `Message`.

This Swift package will not be versioned, and can change over time to reflect changes in `Narratore`, so I advice against linking it directly: simply grab the code that you find useful in your projects, and use it as you see fit 😉.
