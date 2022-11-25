# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH="$HOME/.oh-my-zsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time oh-my-zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="alanpeabody"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git
	zsh-autosuggestions
)

source $ZSH/oh-my-zsh.sh

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"
# Preferred editor for local and remote sessions
# if [[ -n $SSH_CONNECTION ]]; then
#   export EDITOR='vim'
# else
#   export EDITOR='mvim'
# fi

# Compilation flags
# export ARCHFLAGS="-arch x86_64"

# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.


# ALL EXPORTS



# MY CUSTOM ALIAS
######################################################################################################################################################################################################

######################################################################################################################################################################################################

alias zshconfig="vim ~/.zshrc"
alias cstg='cloudctl config use stg'
alias clve='cloudctl config use lve'
alias nl='nslookup'
alias ll="ls -l"
alias slve='sft use splunk'
alias sstg='sft use splunk-stg'
alias cl='cloudctl auth login'
alias vl='vault login -method=okta username=$USER |  egrep -oh "Success! You are now authenticated." '

s()  	{ sft ssh $1 ; }
n()  	{ nslookup $1.splunkcloud.com; }
ad() 	{ PASSWORD=$(vault kv get cloud-sec/std/lve/stacks/$1/admin | grep plaintext | awk {'print $2'} ) ; echo " " ; echo "Password: $PASSWORD" ; echo $PASSWORD  | pbcopy ; echo " " ;echo "Password Copied!" ; }
cm() 	{ sft ssh $(n c0m1.$1 | grep -m 1 canonical | awk -F "[\.=]" '{print $5}'); }
get() 	{ cloudctl stacks get $1 ; }
su() 	{ cloudctl stacks update $1 -f ./$1.yaml --reason "$2"; }
ps() 	{ cd ~/cloud/tools/app-prechecks-script/; python3 ~/cloud/tools/app-prechecks-script/app_pre_checks.py -s $1 -i $2 -p; cd ; }
sa() 	{ cd ~/cloud/backup_tools/app-prechecks-script/; python ~/cloud/backup_tools/app-prechecks-script/app_pre_checks_stackadmin.py -s $1 -i $2; cd ; }
pc() 	{ cd ~/cloud/tools/app-prechecks-script/; python3 ~/cloud/tools/app-prechecks-script/app_pre_checks.py -s $1 -p; cd ; }
jn() 	{ cloudctl stacks get $1 -o json | grep -i lastprovisioned; }
ac() 	{ cd ~/cloud/tools/ ;./appStanza.sh -f $1 -s $2 -t $3; cd ;}
ec() 	{ splunk-vault $1 -f $2.$1.splunkcloud.com; cd ; }
aa() 	{ cd ~/cloud/tools/ ;./appStanza.sh -a $1; cd ; }
si() 	{ cd ~/cloud/tools/ ;python3 splunkbase_info.py -a $1; cd ; }
ss()  	{ sft ssh i-$1 ; }
add() 	{ vault kv get --version $2 cloud-sec/std/lve/stacks/$1/admin;}
ssr() 	{ ssh -F ~/.ssh/sft-config internal-$1.cloud.splunk.com; }
nid()  	{ n $1.$2 | grep -m 1 canonical | awk -F "[\.=]" '{print $5}' | sed 's/ ^*//g' ; }
pso() 	{ cd ~/cloud/backup_tools/app-prechecks-script/; python ~/cloud/backup_tools/app-prechecks-script/app_pre_checks.py -s $1 -i $2 -p; cd ; }
pco() 	{ cd ~/cloud/backup_tools/app-prechecks-script/; python ~/cloud/backup_tools/app-prechecks-script/app_pre_checks.py -s $1; cd ; }
idm() 	{ sft ssh $(n idm1.$1 | grep -m 1 canonical | awk -F "[\.=]" '{print $5}'); }
sh1() 	{ sft ssh $(n sh1.$1 | grep -m 1 canonical | awk -F "[\.=]" '{print $5}'); }
sh2() 	{ sft ssh $(n sh2.$1 | grep -m 1 canonical | awk -F "[\.=]" '{print $5}'); }
sh3() 	{ sft ssh $(n sh3.$1 | grep -m 1 canonical | awk -F "[\.=]" '{print $5}'); }
sh4() 	{ sft ssh $(n sh4.$1 | grep -m 1 canonical | awk -F "[\.=]" '{print $5}'); }
sh5() 	{ sft ssh $(n sh5.$1 | grep -m 1 canonical | awk -F "[\.=]" '{print $5}'); }
backup() {python3 ~/scripts/backup_comms_test.py -a $1 -j $2}
dmc() 	{ sft ssh $(n c0m1.$1 | grep -m 1 canonical | awk -F "[\.=]" '{print $5}') --command 'sudo -u splunk sh -c "cd /opt/splunk/; tail -f var/log/splunk/dmc_agent.log"'; }
ec()	{
fqdn=$(nslookup $2.$1.splunkcloud.com | grep -m 1 canonical | awk -F "[\.=]" '{print $5}' | sed 's/ ^*//g' )
splunk-vault -f $fqdn.$1.splunkcloud.com $1
}


help() {
echo " "; 
echo "|=====================================================================|";
echo "|  1] cl     -->   cloudctl auth login                                |";
echo "|  2] cstg   -->   cloudctl use stg                                   |";
echo "|  3] clve   -->   cloudctl use lve                                   |";
echo "|  4] vl     -->   vault login                                        |";
echo "|  5] ec     -->   Ephemeral Password (Example: ec tide sh1)          |";
echo "|  6] ad     -->   vault admin password get                           |";
echo "|  7] add    -->   vault password get with version                    |";
echo "|  8] s      -->   ssh (Use 'ss' for only SSH)                        |";
echo "|  9] ss     -->   sft ssh with splunk user                           |";
echo "| 10] sstg   -->   swtich sft to splunk-stg                           |";
echo "| 11] slve   -->   switch sft to splunk                               |";
echo "| 12] get    -->   cloudctl stacks get                                |";
echo "| 13] su     -->   cloudctl stacks update                             |";
echo "| 14] ps     -->   app_pre_checks.py   ( ps <stackname> <appid> )     |";
echo "| 15] sa     -->   app_pre_checks_stackadmin.py                       |";
echo "| 16] pc     -->   Custom app precheck  (pc <stackname> <appid>)      |";
echo "| 17] pso    -->   app_pre_checks.py (old)                            |";
echo "| 18] pco    -->   app_pre_checks.py (old custom app)                 |";
echo "| 19] id     -->   Add id_rsa                                         |";
echo "| 20] n      -->   nslookup ( n - *.splunkcloud.com )                 |";
echo "| 21] nl     -->   nslookup                                           |";
echo "| 22] nid    -->   Get FQDN   (Example: nid c0m1 brby )               |";
echo "| 23] jen    -->   get Jenkin Build                                   |";
echo "| 24] si     -->   splunkbase info                                    |";
echo "| 25] ac     -->   appStanza custom app                               |";
echo "| 26] aa     -->   appStanza standard app                             |";
echo "| 27] cc     -->   check ._ in custom app                             |";
echo "| 28] cm     -->   Access c0m1 (Example: cm tide)                     |";
echo "| 29] idm    -->   Access idm (Example: idm tide)                     |";
echo "| 30] sh1    -->   Access SH1 (Example: sh1 tide)                     |";
echo "| 31] sh2    -->   Access SH2 (Example: sh2 tide)                     |";
echo "| 32] dmc    -->   Access DMC logs (Example: dmc tide)                |";
echo "|=====================================================================|"; 
echo " ";
}


######################################################################################################################################################################################################

# ALL EXPORTS

export VAULT_ADDR="https://vault.splunkcloud.systems"
export PATH="$HOME/.yarn/bin:$HOME/.config/yarn/global/node_modules/.bin:$PATH"
export COPYFILE_DISABLE=1
PATH="/Library/Frameworks/Python.framework/Versions/3.9/bin:${PATH}"
export DOCKER_HOST='unix:///Users/dchavda/.local/share/containers/podman/machine/podman-machine-default/podman.sock'

ssh-add ~/.ssh/id_rsa

COPYFILE_DISABLE=1
COPY_EXTENDED_ATTRIBUTES_DISABLE=true
