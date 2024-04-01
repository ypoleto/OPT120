const connection = require('../connection')

const getAllAtividades = async () => {
    const [query] = await connection.execute('SELECT * FROM atividade')
    return query
}
const createAtividade = async (atData) => {
    try {
        const [result] = await connection.execute('INSERT INTO atividade (titulo, `desc`, data) VALUES (?, ?, ?)', [atData.titulo, atData.desc, atData.data]);
        return { id: result.insertId, ...atData };
    } catch (error) {
        throw new Error(`Erro ao criar atividade: ${error.message}`);
    }
}


const getAtividadesById = async (id) => {
    const [query] = await connection.execute('SELECT * FROM atividade WHERE id = ?', [id]);
    return query
}

const updateAtividade = async (atData) => {
   const item = await getAtividadesById(atData.id);
   if (item.length === 0) {
       throw new Error('Atividade não encontrada');
   }
   const [query] = await connection.execute('UPDATE atividade SET titulo = ?, `desc` = ?, data = ? WHERE id =?', [atData.titulo, atData.desc, atData.data, atData.id]);
   return query;
}
const deleteAtividade = async (id) => {
    const item = await getAtividadesById(id);
    if (item.length === 0) {
        throw new Error('Atividade não encontrada');
    }
    const [query] = await connection.execute('DELETE FROM atividade WHERE id = ?', [id]);
    return query
}


module.exports = { getAllAtividades, createAtividade, getAtividadesById, updateAtividade, deleteAtividade }