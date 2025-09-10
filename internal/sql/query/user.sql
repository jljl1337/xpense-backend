-- name: CreateUser :exec
INSERT INTO user (
    id,
    email,
    password_hash,
    created_at,
    updated_at
) VALUES (
    @id,
    @email,
    @password_hash,
    @created_at,
    @updated_at
);

-- name: GetUser :many
SELECT
    *
FROM
    user
WHERE
    id = @id;

-- name: UpdateUser :exec
UPDATE
    user
SET
    email = @email,
    password_hash = @password_hash,
    updated_at = @updated_at
WHERE
    id = @id;

-- name: DeleteUser :exec
DELETE FROM
    user
WHERE
    id = @id;