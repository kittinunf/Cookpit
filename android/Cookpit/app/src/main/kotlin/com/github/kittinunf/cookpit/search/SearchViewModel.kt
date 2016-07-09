package com.github.kittinunf.cookpit.search

import com.github.kittinunf.cookpit.SearchDetailViewData

sealed class SearchViewModelCommand {

    class SetRecentItems(val items: List<String>) : SearchViewModelCommand()
    class SetSearchItems(val items: List<SearchDetailViewData>) : SearchViewModelCommand()

}

data class SearchViewModel(val recentItems: List<String> = listOf(), val searchResults: List<SearchDetailViewData> = listOf()) {

    fun executeCommand(command: SearchViewModelCommand): SearchViewModel {
        when(command) {
            is SearchViewModelCommand.SetRecentItems -> {
                return SearchViewModel(command.items, searchResults)
            }
            is SearchViewModelCommand.SetSearchItems -> {
                return SearchViewModel(recentItems, command.items)
            }
        }
    }

}
