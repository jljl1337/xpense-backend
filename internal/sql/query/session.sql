-- name: CreateSession :one
INSERT INTO session (
    id,
    user_id,
    token,
    csrf_token,
    created_at,
    expires_at
) VALUES (
    @id,
    @user_id,
    @token,
    @csrf_token,
    @created_at,
    @expires_at
)
RETURNING
    *;

-- name: GetSessionByToken :one
SELECT
    *
FROM
    session
WHERE
    token = @token;

-- name: UpdateSession :exec
UPDATE
    session
SET
    expires_at = @expires_at,
    last_used_at = @last_used_at,
    updated_at = @updated_at
WHERE
    id = @id;

-- name: DeleteSession :exec
DELETE FROM
    session
WHERE
    expires_at < @expires_at;