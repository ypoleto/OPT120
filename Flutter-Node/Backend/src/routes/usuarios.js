const { Router } = require('express');
const querys = require('./querysUsuarios');

const router = Router();

router.get('/', async (req, res) => {
    const query = await querys.getAllUsuarios();
    return res.status(200).json(query);
})

router.post('/', async (req, res) => {
    try {
        const userData = req.body; // Dados do novo usuário recebidos no corpo da requisição
        const newUser = await querys.createUsuario(userData); // Chama a função createUsuario para inserir o novo usuário no banco de dados
        return res.status(201).json(newUser); // Retorna os dados do novo usuário com status 201 (Created)
    } catch (error) {
        return res.status(500).json({ error: error.message }); // Retorna um erro interno do servidor se houver algum problema
    }
});

router.get('/:id', async (req, res) => {
    const { id } = req.params;
    const query = await querys.getUsuariosById(id);
    if (query.length === 0) {
        return res.status(404).json({ error: 'Usuário não encontrado.' });
    }
    return res.status(200).json(query);
})

router.put('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const userData = req.body; // Dados do novo usuário recebidos no corpo da requisição
        const query = await querys.updateUsuario(userData); // Chama a função createUsuario para inserir o novo usuário no banco de dados
        if (query === null) {
            return res.status(400).json({ message: 'Usuario não encontrado' }); // Retorna os dados do novo usuário com status 201 (Created)
        }
        return res.status(201).json(query); // Retorna os dados do novo usuário com status 201 (Created)
    } catch (error) {
        return res.status(500).json({ error: error.message }); // Retorna um erro interno do servidor se houver algum problema
    }
});

router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    const query = await querys.deleteUsuario(id);
    if (query === null) {
        return res.status(404).json({ error: 'Usuário não encontrado.' });
    }
    return res.status(200).json(query);
})


module.exports = router;