# Movie Database Application
## Description
Movie Database Application is an iOS mobile application that allows user to search for movies in [The Movie Database](https://developers.themoviedb.org/3/getting-started/introduction) and displays results in a simple and neat UI. The application uses [TheMovieDatabaseSwiftWrapper](https://github.com/gkye/TheMovieDatabaseSwiftWrapper) to fetch response from the Movie Database API.

## Features

### Top Movies & Upcoming Movies
- Top movies and upcoming movies, both of them are displayed in a 2-column fashion.
- A search bar is provided to narrow down the results displayed. Care is taken to ensure search results are optimized without any lag.

  | Top Movies                                                 | Upcoming Movies                                            |
  |------------------------------------------------------------|------------------------------------------------------------|
  | <img src="./resources/top-movies.png" width="250"/>        | <img src="./resources/upcoming-movies.png" width="250"/>   |

#
### Search Movies
- The view provides results by two ways:
  1) Auto search results are displayed at the text field as the user enters the letters.
  2) When user clicks the search button i.e the magnifying glass, the results are neatly displayed in a table view.

| Search                                        |  Textfield Results                            | Table View Results     |
|-----------------------------------------------|-----------------------------------------------|------------------------|
|<img src="./resources/search.png" width="250"/>|<img src="./resources/searchtextfield.png" width="250"/>|<img src="./resources/table-results.png" width="250"/>| 
 
#  
## Save and Delete
- The view shows details of the selected movie.
- The movie can be saved to the database to help user check the movie info without network. The saved movie can also be deleted.
- Movies are saved and deleted using [Realm](https://realm.io/docs/swift/latest/) database.

Details                                          | Save Movies                                  | Delete Movies              |
-------------------------------------------------|----------------------------------------------|----------------------------|
<img src="./resources/detail-2.png" width="250"/>| <img src="./resources/save.png" width="250"/>| <img src="./resources/delete.png" width="250"/>|
