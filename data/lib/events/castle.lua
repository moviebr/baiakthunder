-- Créditos ao Lyu e Gengo que ajudaram em coisas focais desse script
-- Código testado em TFS 1.3 na versão 8.60

config = {
castleNome = "[Castle 24H]", -- Prefixo que irá aparecer nas mensagens
mensagemPrecisaGuild = "Você precisa fazer parte de alguma guild para invadir o castelo.", -- Mensagem que irá aparecer caso o player não tenha guild
mensagemGuildDominante = "O castelo já é da sua guild.", -- Mensagem caso o player tente dominar o castelo mesmo sendo da sua guild
mensagemGuildNaoDominante = "O castelo não é da sua guild", -- Caso o castelo não seja da guild do player
mensagemLevelMinimo = "Você não tem level suficiente para invadir o castelo.", -- Caso o player não tenha nível para entrar
mensagemBemvindo = "Seja bem vindo ao seu castelo.", -- Mensagem de bem-vindo à guild dominante
levelParaDominar = true, -- true para precisar de nivel para dominar e false para não precisar
level = 100, -- caso o levelParaDominar seja true, qual o nivel?
tempoAvisar = 10, -- Tempo em SEGUNDOS para não ficar spammando que o player está invadindo
}

function getGuildIdFromCastle() -- Por Gengo e Movie
  local guildId  = -1
  local resultId = db.storeQuery("SELECT `guild_id` FROM `castle`;")
  if (resultId ~= false) then
    guildId = result.getDataInt(resultId, "guild_id")
    result.free(resultId)
  end
  return guildId  
end