package com.github.kittinunf.cookpit.explore

import com.github.kittinunf.cookpit.ExploreDetailViewData

sealed class ExploreViewModelCommand {

    class SetItems(val items: List<ExploreDetailViewData>) : ExploreViewModelCommand()

}

data class ExploreViewModel(val items: List<ExploreDetailViewData>) {

    fun executeCommand(command: ExploreViewModelCommand): ExploreViewModel {
        when(command) {
            is ExploreViewModelCommand.SetItems -> {
                return ExploreViewModel(command.items)
            }
        }
    }

}

