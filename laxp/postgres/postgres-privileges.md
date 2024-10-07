Each of these queries focuses on a different aspect of privileges and should provide a thorough overview of access permissions within your PostgreSQL environment.

# Database-Level Privileges
lists all privileges granted to users on the databases
```
SELECT
    pg_database.datname AS database_name,
    pg_roles.rolname AS role_name,
    has_database_privilege(pg_roles.rolname, pg_database.datname, 'CONNECT') AS connect_privilege,
    has_database_privilege(pg_roles.rolname, pg_database.datname, 'CREATE') AS create_privilege,
    has_database_privilege(pg_roles.rolname, pg_database.datname, 'TEMPORARY') AS temporary_privilege
FROM
    pg_database
CROSS JOIN
    pg_roles
ORDER BY
    pg_database.datname, 
    pg_roles.rolname;
```

# Schema-Level Privileges
lists all privileges granted to users on schemas
```
SELECT 
    n.nspname AS schema_name,
    r.rolname AS role_name,
    has_schema_privilege(r.rolname, n.nspname, 'USAGE') AS usage_privilege,
    has_schema_privilege(r.rolname, n.nspname, 'CREATE') AS create_privilege
FROM 
    pg_namespace n
CROSS JOIN 
    pg_roles r
WHERE 
    n.nspname NOT LIKE 'pg_%' AND n.nspname != 'information_schema'
ORDER BY 
    n.nspname, 
    r.rolname;
```

# Table-Level Privileges
lists all privileges granted to users on tables
```
SELECT 
    grantee AS role_name,
    table_schema,
    table_name,
    string_agg(privilege_type, ', ') AS privileges
FROM 
    information_schema.role_table_grants
GROUP BY 
    grantee, table_schema, table_name
ORDER BY 
    table_schema, table_name, role_name;
```

# Column-Level Privileges
```
SELECT 
    grantee AS role_name,
    table_schema,
    table_name,
    column_name,
    privilege_type
FROM 
    information_schema.column_privileges
ORDER BY 
    table_schema, table_name, column_name, role_name;
```
# Sequence-Level Privileges
```
SELECT 
    grantee AS role_name,
    sequence_schema,
    sequence_name,
    privilege_type
FROM 
    information_schema.role_sequence_grants
ORDER BY 
    sequence_schema, sequence_name, role_name;
```
# Function-Level Privileges
```
SELECT 
    grantee AS role_name,
    routine_schema,
    routine_name,
    privilege_type
FROM 
    information_schema.role_routine_grants
ORDER BY 
    routine_schema, routine_name, role_name;
```
# Default Privileges
This query lists default privileges that apply to objects created by a specific user in the future
```
SELECT 
    r.rolname AS role_name,
    nspname AS schema_name,
    defaclobjtype AS object_type,
    array_agg(privilege_type) AS privileges
FROM 
    pg_default_acl
JOIN 
    pg_namespace ON pg_default_acl.defaclnamespace = pg_namespace.oid
JOIN 
    pg_roles r ON pg_default_acl.defaclrole = r.oid
JOIN 
    unnest(pg_default_acl.defaclacl) acl ON true
JOIN 
    (VALUES ('r', 'SELECT'),
                ('a', 'INSERT'),
                ('w', 'UPDATE'),
                ('d', 'DELETE'),
                ('D', 'TRUNCATE'),
                ('x', 'REFERENCES'),
                ('t', 'TRIGGER'),
                ('X', 'EXECUTE'),
                ('U', 'USAGE')) acl_mappings (acl_char, privilege_type)
    ON acl.privilege::text = acl_mappings.acl_char
GROUP BY 
    r.rolname, nspname, defaclobjtype
ORDER BY 
    r.rolname, nspname, defaclobjtype;
```
