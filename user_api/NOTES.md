# Practice 11 Notes

## HTTP Observations
- `GET /users`: Status `200 OK`, `Content-Type: application/json; charset=utf-8`, returns a JSON array of 10 users.
- `GET /users/999`: Status `404 Not Found`, body is `{}`.
- `POST /users`: Status `201 Created`, server echoes the sent JSON and appends `"id": 11`.
- `GET /users?id=3`: Returns a JSON list containing 1 object `[ {...} ]`, not a single object.

## User Fields (Top-level)
| Field | JSON Type | Dart Type | Nullable? |
| :--- | :--- | :--- | :--- |
| id | number | int | no |
| name | string | String | no |
| username | string | String | no |
| email | string | String | no |
| address | object | Address | no |
| phone | string | String | no |
| website | string | String? | yes |
| company | object | ({String name, String catchPhrase}) | no |

## Address Fields
| Field | JSON Type | Dart Type | Nullable? |
| :--- | :--- | :--- | :--- |
| street | string | String | no |
| suite | string | String | no |
| city | string | String | no |
| zipcode | string | String | no |
| geo | object | Geo | no |

## Geo Fields (Nested twice)
| Field | JSON Type | Dart Type | Nullable? |
| :--- | :--- | :--- | :--- |
| lat | string | double (via double.parse) | no |
| lng | string | double (via double.parse) | no |

## Company Fields
| Field | JSON Type | Dart Type | Nullable? |
| :--- | :--- | :--- | :--- |
| name | string | String | no |
| catchPhrase | string | String | no |
| bs | string | String (ignored in model) | no |

## No-Network Timings (Level 5)
- Airplane mode: ~0.1 sec (immediate SocketException)
- Dead Wi-Fi (no internet): ~10.0 sec (TimeoutException)