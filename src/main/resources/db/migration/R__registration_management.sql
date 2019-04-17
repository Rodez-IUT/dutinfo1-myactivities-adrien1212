create or replace function register_user_on_activity(in_user_id bigint, in_activity_id bigint)
    returns registration as $$
    declare
        res_registration registration%rowtype;
    begin
        -- check existence
        select * into res_registration from registration
        where user_id = in_user_id and activity_id = in_activity_id;
        if FOUND then
            raise exception 'registration_already_exists';
        end if;
        -- insert
        insert into registration (id, user_id, activity_id)
        values(nextval('id_generator'), in_user_id, in_activity_id);
        -- returns result
        select * into res_registration from registration
        where user_id = in_user_id and activity_id = in_activity_id;
        return res_registration;
    end;
$$ language plpgsql;



CREATE OR REPLACE FUNCTION unregister_user_on_activity(in_user_id bigint, in_activity_id bigint) RETURNS void AS $$

    DECLARE
        res_registration registration%rowtype;

    BEGIN
        SELECT * INTO res_registration
        FROM registration
        WHERE user_id = in_user_id
        AND activity_id = in_activity_id;
        
        IF NOT FOUND THEN
            RAISE NOTICE 'L utilisateur % n a pas été trouvé pour l activité %', in_user_id, in_activity_id; 
        END IF;  
        
         
        DELETE FROM registration
        WHERE user_id = in_user_id
        AND activity_id = in_activity_id;
        
    END;
$$ language plpgsql;


DROP TRIGGER IF EXISTS log_register on registration;
DROP TRIGGER IF EXISTS log_unregister on registration;

CREATE OR REPLACE FUNCTION log_register() RETURNS trigger AS $$
	BEGIN
		INSERT INTO action_log (id, action_name, entity_name, entity_id, author, action_date)
		VALUES (nextval('id_generator'),'insert','registration', NEW.id, user, now());
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_register
	AFTER INSERT ON registration
	FOR EACH ROW
	EXECUTE PROCEDURE log_register();
	
CREATE OR REPLACE FUNCTION log_unregister() RETURNS trigger AS $$
	BEGIN
		INSERT INTO action_log (id, action_name, entity_name, entity_id, author, action_date)
		VALUES (nextval('id_generator'),'delete','registration', OLD.id, user, now());
		RETURN NULL;
	END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER log_unregister
	AFTER DELETE ON registration
	FOR EACH ROW
	EXECUTE PROCEDURE log_unregister();