function _sanapasti-ssh(){
	local state
	_arguments "1: :($(~/.sanapasti/interact/sanapasti-ls --list|  tr '\n' ' '))"
}

function _sanapasti-restore(){
	local state
	_arguments "1: :($(ls ~/.sanapasti/backup/))"
}
function _sanapasti-deploy(){
	local state
	_arguments "1: :($(ls ~/.sanapasti/profiles/))"
}
