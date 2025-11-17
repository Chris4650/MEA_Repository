# Microservices

## Cohesion vs. Coupling

### Cohesion

**Cohesion** refers to how closely related the responsibilities within a single service are. High cohesion means that a service focuses on doing one thing well, with all its functions supporting that single purpose.

**Spotify Example:**

- **High Cohesion (Good)**: The **Music Player Service** handles everything related to playing music - play, pause, skip, volume control, background playback. All these functions are closely related to the core purpose of playing audio.
- **Low Cohesion (Bad)**: If the Music Player Service also handled user authentication, playlist creation, and payment processing, it would have low cohesion because these responsibilities are unrelated to playing music.

### Coupling

**Coupling** refers to how much one service depends on another. Low coupling is desirable because it means services can be changed, deployed, or scaled independently without affecting others.

**Spotify Example:**

- **Low Coupling (Good)**: The **Favorites Service** sends a message "User liked Song X" to an event queue. Other services (like Recommendations) can listen to this event if they want, but the Favorites Service doesn't need to know about them.
- **High Coupling (Bad)**: If the Favorites Service had to directly call the Recommendations Service, the User Profile Service, and the Analytics Service every time someone favorited a song, these services would be tightly coupled and changes to any would affect the others.

---

## Types of Coupling

### Domain Coupling

**Domain Coupling** occurs when one service needs to interact with another because they operate in related business domains. This is often necessary and acceptable.

**Spotify Example:**
The **Playlist Service** has domain coupling with the **Music Library Service** because to create a playlist, it needs to verify that songs exist in the library. When a user adds "Bohemian Rhapsody" to a playlist, the Playlist Service must call the Music Library Service to get the song's metadata (artist, album, duration).

```javascript
// Playlist Service needs to talk to Music Library Service
async function addSongToPlaylist(playlistId, songId) {
  // Domain coupling - we need song info from another service
  const song = await musicLibraryService.getSong(songId);
  if (!song) throw new Error("Song not found");

  return playlist.addSong({
    id: songId,
    title: song.title,
    artist: song.artist,
  });
}
```

### Pass-Through Coupling

**Pass-Through Coupling** happens when Service A receives data only to pass it to Service B, without actually using it. This is a code smell because Service A becomes a middleman unnecessarily.

**Spotify Example (Bad):**
Imagine the **User Interface Service** receives a song recommendation request, gets a user token, and passes it through to the **Recommendation Service**, which then passes it through to the **User Profile Service** to get listening history. The Recommendation Service doesn't need the token itself - it's just passing it along.

```javascript
// BAD: Pass-through coupling
async function getRecommendations(userToken) {
  // We're just passing userToken through without using it
  const recommendations = await recommendationService.suggest(userToken);
  return recommendations;
}
```

**Better Approach:**
The UI Service should call User Profile Service directly to get what's needed, then send relevant data to the Recommendation Service.

### Common Coupling

**Common Coupling** occurs when multiple services read from and write to the same shared data source, like a database table. This creates dependencies and can lead to conflicts.

**Spotify Example (Bad):**
If both the **Playlist Service** and the **Favorites Service** directly write to the same `user_preferences` database table, they have common coupling. If the Playlist Service changes the table schema, the Favorites Service might break.

```sql
-- BAD: Both services writing to same table
-- Playlist Service writes:
INSERT INTO user_preferences (user_id, type, item_id)
VALUES (123, 'playlist', 456);

-- Favorites Service also writes:
INSERT INTO user_preferences (user_id, type, item_id)
VALUES (123, 'favorite', 789);
```

**Better Approach:**
Each service should own its own database. If they need to share data, they should communicate through APIs or events.

### Content Coupling

**Content Coupling** is the worst type - it happens when one service directly accesses or modifies the internal data or behavior of another service, bypassing its API.

**Spotify Example (Very Bad):**
If the **Recommendation Service** directly queries the **Music Player Service's** internal database to see what users are listening to right now, instead of using the Music Player Service's API, that's content coupling.

```javascript
// VERY BAD: Content coupling
async function getUserCurrentSong(userId) {
  // Directly accessing another service's database!
  const result = await otherServiceDatabase.query(
    "SELECT current_song FROM player_state WHERE user_id = ?",
    [userId]
  );
  return result;
}
```

**Why It's Bad:**
If the Music Player Service changes how it stores data, the Recommendation Service breaks. Services should always communicate through well-defined interfaces (APIs).

---

## Microservices Patterns

### Synchronous Blocking

In **synchronous blocking** communication, Service A calls Service B and waits for a response before continuing. The request "blocks" until it gets an answer.

**Spotify Example:**
When a user clicks "Play" on a song, the **Music Player Service** makes a synchronous call to the **Music Library Service** to get the audio file URL. The player must wait for this URL before it can start playing.

```javascript
// Synchronous blocking call
async function playSong(songId) {
  console.log("Requesting song URL...");

  // Player waits here until library responds
  const audioUrl = await musicLibraryService.getAudioUrl(songId);

  console.log("Got URL, starting playback");
  return player.play(audioUrl);
}
```

**Pros:** Simple to understand, immediate response
**Cons:** If the Music Library Service is slow or down, the player can't work

### Asynchronous Non-Blocking

In **asynchronous non-blocking** communication, Service A sends a message and continues working without waiting for a response. The response might come later, or not at all.

**Spotify Example:**
When a user likes a song, the **Favorites Service** publishes an event "Song Liked" to a message queue. The **Recommendation Service** can process this event later to update recommendations. The user doesn't have to wait - they see "❤️ Liked" immediately.

```javascript
// Asynchronous non-blocking
async function likeSong(userId, songId) {
  // Save to database immediately
  await favorites.add(userId, songId);

  // Publish event without waiting for subscribers
  eventBus.publish("song.liked", {
    userId,
    songId,
    timestamp: Date.now(),
  });

  // Return immediately - don't wait for recommendation service
  return { success: true };
}

// Elsewhere, Recommendation Service listens
eventBus.subscribe("song.liked", async (event) => {
  // This happens later, asynchronously
  await updateUserTasteProfile(event.userId, event.songId);
});
```

**Pros:** Fast response, services don't block each other, resilient
**Cons:** More complex, eventual consistency (data might not be immediately up-to-date everywhere)

### Communication Through Common Data

Services communicate by reading and writing to a shared data store. This is generally discouraged in microservices architecture.

**Spotify Example (Discouraged):**
Both the **Playlist Service** and the **Recently Played Service** write to a shared `user_activity` table. The Recently Played Service polls this table to see what songs were added to playlists.

**Why It's Problematic:**

- Creates common coupling (discussed above)
- Hard to scale independently
- Schema changes affect multiple services
- Unclear ownership of data

**Better Approach:** Use events or APIs instead.

---

## Communication Patterns

### Request-Response Communication

**Request-Response** is a synchronous pattern where one service sends a request and expects a specific response. This is like a phone call - you ask a question and wait for an answer.

**Spotify Example:**
When building the user's home screen, the **UI Service** makes request-response calls to multiple services:

```javascript
async function buildHomeScreen(userId) {
  // Request 1: Get user info
  const user = await userService.getUser(userId);

  // Request 2: Get playlists
  const playlists = await playlistService.getUserPlaylists(userId);

  // Request 3: Get recommendations
  const recommendations = await recommendationService.getSuggestions(userId);

  // Request 4: Get recently played
  const recentlyPlayed = await historyService.getRecentlyPlayed(userId);

  return {
    user,
    playlists,
    recommendations,
    recentlyPlayed,
  };
}
```

**When to Use:**

- Need immediate answer
- Require data to proceed
- Simple queries

**Protocol Examples:** HTTP/REST, gRPC

### Event-Driven Communication

**Event-Driven** is an asynchronous pattern where services publish events when something happens, and other services can subscribe to events they care about. This is like a radio broadcast - the publisher announces to anyone who's listening.

**Spotify Example:**
When a user finishes listening to a song, multiple services care about this event:

```javascript
// Music Player publishes an event
async function onSongFinished(userId, songId) {
  eventBus.publish("song.completed", {
    userId,
    songId,
    timestamp: Date.now(),
    duration: 245, // seconds
    completionPercentage: 100,
  });
}

// Multiple services subscribe:

// History Service - adds to listening history
eventBus.subscribe("song.completed", async (event) => {
  await historyService.recordPlay(event.userId, event.songId);
});

// Recommendation Service - updates user preferences
eventBus.subscribe("song.completed", async (event) => {
  await recommendationService.updateTaste(event.userId, event.songId);
});

// Analytics Service - tracks engagement
eventBus.subscribe("song.completed", async (event) => {
  await analyticsService.recordEngagement(event);
});

// Artist Royalty Service - calculates payments
eventBus.subscribe("song.completed", async (event) => {
  if (event.completionPercentage >= 30) {
    await royaltyService.recordPlay(event.songId);
  }
});
```

**When to Use:**

- Multiple services need to know about an event
- Don't need immediate response
- Want loose coupling between services
- Event might trigger multiple actions

**Technology Examples:** RabbitMQ, Apache Kafka, AWS SNS/SQS, Redis Pub/Sub

---

## Key Takeaways for Spotify-Like App Architecture

A well-designed Spotify-like app would have these separate microservices:

1. **User Service** - Authentication, profiles, subscriptions
2. **Music Library Service** - Song metadata, albums, artists, audio files
3. **Playlist Service** - Creating, editing, sharing playlists
4. **Favorites Service** - Liked songs, albums, artists
5. **Music Player Service** - Play/pause, queue management, background playback
6. **Recommendation Service** - Suggestions based on listening history
7. **History Service** - Recently played tracks
8. **Search Service** - Finding songs, albums, artists, playlists

**Communication Strategy:**

- **Synchronous/Request-Response**: When immediate data is needed (e.g., fetching song details to play)
- **Asynchronous/Event-Driven**: When notifying about user actions (e.g., song liked, song completed)
- **Low Coupling**: Services communicate through APIs and events, not shared databases
- **High Cohesion**: Each service focuses on one domain (playing, recommending, organizing, etc.)

---

# Code Snippets

## HTTP Request Properties in Express.js

```javascript
// Common request properties when building microservices with Express
app.get("/api/songs/:id", (req, res) => {
  // req.url - full URL path: '/api/songs/123?format=mp3'
  // req.query - query parameters: { format: 'mp3' }
  // req.method - HTTP method: 'GET'
  // req.params - route parameters: { id: '123' }
  // req.body - request body (from POST/PUT)
  // req.headers - HTTP headers

  const songId = req.params.id;
  const format = req.query.format || "mp3";

  res.json({ songId, format });
});
```
