/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.up = function(knex) {
  return knex.schema.createTable('usuarios', (table) => {
    table.increments('id').primary(); // id (pk) INT Autoincrement
    table.string('name').notNullable(); // name VARCHAR
    table.string('last_name').notNullable(); // last_name VARCHAR
    table.boolean('isAdmin').defaultTo(false); // IsAdmin BOOLEAN
    table.string('email').unique().notNullable(); // email VARCHAR (Único)
    table.string('password').notNullable(); // password VARCHAR
    table.timestamps(true, true); // Crea created_at y updated_at (Opcional, pero recomendado)
  });
};

/**
 * @param { import("knex").Knex } knex
 * @returns { Promise<void> }
 */
exports.down = function(knex) {
  return knex.schema.dropTable('usuarios');
};
