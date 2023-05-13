# NYTimes
NY Times Most Popular Articles - Assessment For **Avrioc Technologies**

## OverView
     
Simple **iOS App** to hit the NY Times Most Popular Articles API and show a list of articles,
that shows details when items on the list are tapped

## Demo

![Demo](ReadMe/Demo.gif)

## Features

1. **MVC Architecture**: The app follows the Model-View-Controller (MVC) architectural pattern, separating the concerns of data management, presentation, and user interaction. This promotes code organization, reusability, and maintainability.

2. **Core Data Integration**: The app incorporates `NSFetchedResultsController` and Core Data to efficiently manage and display the list of articles. It provides thread-safe background support, allowing seamless syncing with the API. This ensures that data updates from the API are safely managed in the background without affecting the app's main thread and user interface.

3. **Media Caching**: The app includes a `MediaCache` class that provides a thread-safe mechanism for caching images. This ensures efficient retrieval and display of article images, enhancing the user experience.

4. **Pull-to-Refresh Support**: The app includes a pull-to-refresh feature, allowing users to manually trigger the refreshing of the article list. By pulling down on the list, users can easily update the content to see the latest articles from the API.

5. **Dark Mode Support**: The app supports dark mode, adapting its appearance to match the user's system preferences. Whether the device is in light or dark mode, the app provides a visually consistent and appealing experience.

6. **Adaptive Layout**: The app utilizes adaptive layouts to ensure optimal presentation and usability across various screen sizes and orientations. It dynamically adjusts the interface elements and layout constraints to accommodate different device sizes, including iPhones and iPads.

7. **Localization**: The app supports multiple languages through localization. It provides translations for different languages, enabling users from different regions to use the app in their preferred language.

## Requirements

To run the NY Times Most Popular Articles App, you will need the **Xcode**

##  Test Cases

To Generate **coverage report**, Do the following:

1. Open the `NYTimes.xcodeproj` file in Xcode.

2. Select the target you want to test:
    • For API test cases, select the NYTimesApiTests target.
    • For UI test cases, select the NYTimesUITests target.    
    
3. Build and run the tests by choosing "Product" -> "Test" from the Xcode menu bar, or by pressing Cmd + U.

4. Xcode will run the tests and display the test results and coverage report in the Test Navigator and the console output.

The unit tests in this project cover the following functionality:

### Api Tests

1. `test_MostPopularList_Api_url_builder`: This test verifies the correctness of the URL builder for the Most Popular Articles API request. It checks that the generated URL matches the expected URL format.

2. `test_MostPopularList_Api_Result`: This test performs an actual API request to the Most Popular Articles API and validates the response. It checks that the API call is successful and that the returned articles results are not empty.

3. `test_MediaCache`: This test validates the functionality of the MediaCache class. It verifies that the image caching mechanism works correctly by retrieving an image from a given URL and checking if it is successfully cached.

### UI Testing

1. `testLaunchPerformance`: This test measures the time it takes to launch the NY Times app. It provides insights into the performance of the app launch process.

2. `testAppUI`: This test verifies the user interface of the app. It launches the app, waits for a specific UI element to appear, taps on a cell, verifies the details page, checks the existence of UI elements, and performs UI interactions.
