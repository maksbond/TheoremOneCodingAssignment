# TheoremOneCodingAssignment

## Achitecture

For this test, I selected MVVM architecture because it fully covers all needs:
- Simple for implementation
- Removes MVC issue with "MASSIVE" controller
- Provides good business logic separation

## Requirements

- Xcode 14.0+
- iOS 15.0+
- To run app just open .xcodeproj file with Xcode.app

## Details

- All UI created with code instead of Storyboards and Xib files (except LaunchScreen)
- async/await mechanism for network calls
- POP mechanism used for easier testing
- @MainActor for operations in the main thread
- no additional libraries are used. It removes the dependency on 3rd-party libraries
- network layer testing is inspired by [this article](https://medium.com/@dhawaldawar/how-to-mock-urlsession-using-urlprotocol-8b74f389a67a)

## Important

- I skipped testing for UI and dataSources to save time
- I tried to add some basic logs to simplify work during debugging. Moreover, logs should be accessible through Console.app on Mac.
