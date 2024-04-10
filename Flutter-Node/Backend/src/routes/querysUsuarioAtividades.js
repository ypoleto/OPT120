const connection = require('../connection')

const getAllUsuarioAtividades = async () => {
    const [query] = await connection.execute(`
    SELECT ua.id AS usuario_atividade_id, 
           ua.entrega, 
           ua.nota, 
           ua.id AS usuario_atividade_id,
           a.desc AS atividade_descricao, 
           u.email AS usuario_email, 
           u.nome AS usuario_nome, 
           u.senha AS usuario_senha, 
           a.titulo AS atividade_titulo 
    FROM usuario_atividades ua
    JOIN usuario u ON ua.usuario_id = u.id
    JOIN atividade a ON ua.atividade_id = a.id;
        `)
    return query
}
const createUsuarioAtividades = async (userData) => {
    try {
        const [result] = await connection.execute('INSERT INTO usuario_atividades (usuario_id, atividade_id, entrega, nota) VALUES (?, ?, ?, ?)', [userData.usuario_id, userData.atividade_id, userData.entrega, userData.nota]);
        return { id: result.insertId, ...userData };
    } catch (error) {
        throw new Error(`Erro ao criar usuário-atividade: ${error.message}`);
    }
}

const getUsuarioAtividadesById = async (id) => {
    const [query] = await connection.execute('SELECT * FROM usuario_atividades WHERE id = ?', [id]);
    return query
}

const updateUsuarioAtividades = async (userData) => {
   const item = await getUsuarioAtividadesById(userData.id);
   if (item.length === 0) {
       throw new Error('Não encontrado');
   }
   const [query] = await connection.execute('UPDATE usuario_atividades SET usuario_id = ?, atividade_id = ?, entrega = ?, nota = ? WHERE id =?', [userData.usuario_id, userData.atividade_id, userData.entrega, userData.nota, userData.id]);
   return query;
}
const deleteUsuarioAtividades = async (id) => {
    const item = await getUsuarioAtividadesById(id);
    if (item.length === 0) {
        throw new Error('Não encontrado');
    }
    const [query] = await connection.execute('DELETE FROM usuario_atividades WHERE id = ?', [id]);
    return query
}





module.exports = { getAllUsuarioAtividades, createUsuarioAtividades, getUsuarioAtividadesById, updateUsuarioAtividades, deleteUsuarioAtividades }