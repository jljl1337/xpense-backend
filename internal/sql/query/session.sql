-- name: CreateSession :exec
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
);

