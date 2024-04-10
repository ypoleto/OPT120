const { Router } = require('express');
const querys = require('./querysUsuarioAtividades');

const router = Router();

router.get('/', async (req, res) => {
    const query = await querys.getAllUsuarioAtividades();
    return res.status(200).json(query);

    
})

router.post('/', async (req, res) => {
    try {
        const atividadeData = req.body; 
        const newAt = await querys.createUsuarioAtividades(atividadeData);
        return res.status(201).json(newAt); 
    } catch (error) {
        return res.status(500).json({ error: error.message });
    }
});

router.get('/:id', async (req, res) => {
    const { id } = req.params;
    const query = await querys.getUsuarioAtividadesById(id);
    if (query.length === 0) {
        return res.status(404).json({ error: 'Não encontrada.' });
    }
    return res.status(200).json(query);
})

router.put('/:id', async (req, res) => {
    const { id } = req.params;
    try {
        const atividadeData = req.body; // Dados do novo atividade recebidos no corpo da requisição
        const query = await querys.updateUsuarioAtividades(atividadeData); // Chama a função createAtividade para inserir o novo atividade no banco de dados
        if (query === null) {
            return res.status(400).json({ message: 'Não encontrada' }); // Retorna os dados do novo atividade com status 201 (Created)
        }
        return res.status(201).json(query); // Retorna os dados do novo atividade com status 201 (Created)
    } catch (error) {
        return res.status(500).json({ error: error.message }); // Retorna um erro interno do servidor se houver algum problema
    }
});

router.delete('/:id', async (req, res) => {
    const { id } = req.params;
    const query = await querys.deleteUsuarioAtividades(id);
    if (query === null) {
        return res.status(404).json({ error: 'Não encontrada.' });
    }
    return res.status(200).json(query);
})


module.exports = router;