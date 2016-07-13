package com.github.kittinunf.cookpit.explore

import com.github.kittinunf.cookpit.ExploreDetailViewData

sealed class ExploreViewModelCommand {

    class SetItems(val items: List<ExploreDetailViewData> = listOf()) : ExploreViewModelCommand()

}

data class ExploreViewModel(val items: List<ExploreDetailViewData> = listOf()) {

    fun executeCommand(command: ExploreViewModelCommand): ExploreViewModel {
        when(command) {
            is ExploreViewModelCommand.SetItems -> {
                return ExploreViewModel(command.items)
            }
        }
    }

}

