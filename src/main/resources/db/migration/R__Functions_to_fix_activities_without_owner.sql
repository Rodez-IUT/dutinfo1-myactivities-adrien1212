CREATE OR REPLACE FUNCTION get_default_owner() RETURNS "user" AS $$
	DECLARE
		defaultOwner "user"%ROWTYPE;
		defaultOwnerUsername VARCHAR(500) := 'Default Owner';
	BEGIN
	    SELECT * INTO defaultOwner FROM "user" WHERE username = defaultOwnerUsername;
    	IF not found THEN
        	INSERT INTO "user" VALUES (nextval('id_generator'),defaultOwnerUsername);
        	SELECT * INTO defaultOwner FROM "user" WHERE username = defaultOwnerUsername;
    	END IF;
    	RETURN defaultOwner;
    END
$$ LANGUAGE PLPGSQL;


CREATE OR REPLACE FUNCTION fix_activities_without_owner() RETURNS SETOF activity AS $$
    DECLARE
        defaultOwner "user"%ROWTYPE;
    BEGIN
        defaultOwner := get_default_owner();
        RETURN QUERY
        UPDATE activity
        SET owner_id = defaultOwner.id
        WHERE owner_id is null
        RETURNING *;
    END
$$ LANGUAGE PLPGSQL;