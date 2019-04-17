CREATE OR REPLACE FUNCTION get_default_owner() RETURNS "user" AS $$
	DECLARE
		defaultOwner "user"%rowtype;
		defaultOwnerUsername varchar(500) := 'Default Owner';
		
	BEGIN
		SELECT * into defaultOwner
		FROM "user" 
		WHERE username = defaultOwnerUsername ;
	
		IF NOT FOUND THEN
			INSERT INTO "user" (id, username) VALUES (nextval('id_generator'), 'Default Owner');
			SELECT * into defaultOwner
			FROM "user" 
			WHERE username =defaultOwnerUsername ;
		END IF;
		RETURN defaultOwner;
	END
$$ LANGUAGE plpgSQL;

CREATE OR REPLACE FUNCTION fix_activities_without_owner() RETURNS SETOF activity AS $$
	DECLARE
		defaultOwner "user"%rowtype;
		nowDate date = now();		
	BEGIN
		defaultOwner := get_Default_Owner();
		RETURN QUERY 
			UPDATE activity 
			SET owner_id = defaultOwner.id,
			modification_date = nowDate
				WHERE owner_id IS NULL
			RETURNING *;		
	END
$$ LANGUAGE plpgSQL;