# Pokémon Card Studio - IT 126 Module 3 Lesson 4

## Overview
This Flutter application demonstrates asynchronous communication with a remote REST service (`PokeAPI`). Users can type any Pokémon name in the search field to dynamically fetch, decode, and render its trading card details.

## Implementation Details

### 1. Handling Successful Requests
- Uses the `http` package to submit a `GET` request to `https://pokeapi.co/api/v2/pokemon/{name}`.
- Upon receiving a `200 OK` HTTP status code, the response body text is parsed using `json.decode()` from `dart:convert`.
- The decoded map is mapped into the `Pokemon` data model using factory constructors and injected into the reactive state to redraw the UI card.

### 2. Handling Unsuccessful Responses & Errors
- **Client/Not Found Errors (404):** If a user searches for an invalid or non-existent Pokémon (e.g., `thispokemondoesnotexist`), the application checks the HTTP status code and displays a friendly error message (`"Pokémon not found..."`) rather than crashing or mapping invalid data.
- **Network Failures & Exceptions:** Wrapped in a `try-catch` block to gracefully capture dropped or disconnected internet connections, notifying the user immediately.
- **Concurrency Prevention:** The search text field and button are disabled (`_isLoading`) while an active network fetch is underway to prevent duplicate overlapping requests.

### 3. Proposed Offline Strategy
*Although local database caching was not built into this iteration, an offline-first architecture could be achieved by integrating **Hive** or **SQLite (sqflite)**:*
1. **Local Cache Layer:** When a successful network response is received, serialize the `Pokemon` object's `toJson()` map and save it into a local key-value store keyed by its lowercase name or ID.
2. **Connectivity Check:** Use a connectivity plugin to detect whether the device has internet access.
3. **Fallback Mechanism:** If offline or if an API request throws a network failure exception, the app queries the local storage database for the cached JSON entry, allowing users to view previously inspected cards offline.