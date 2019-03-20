CREATE OR REPLACE FUNCTION get_default_owner() RETURNS "user" AS $$
    
    DECLARE
        nbUserDefault "user"%rowtype;
        DefaultName varchar(500) := 'Default owner';
    BESING
    
        SELECT * INTO nbUserDefault
        FROM "user"
        WHERE DefaultName := 'Default owner';
    
        IF not found THEN
            RETURN 	"user";
        ELSE
            INSERT INTO "user" (id, username)
            VALUES (nextval('id-generator'), "Default owner");
            
            SELECT * INTO nbUserDefault
            FROM "user"
            WHERE DefaultName := 'Default owner';
            
            RETURN "user";
        END IF
    
    
        RETURN username
    END
$$ LANGUAGE plpgsql;