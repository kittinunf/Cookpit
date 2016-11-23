package com.github.kittinunf.cookpit.photo


import com.github.kittinunf.cookpit.PhotoCommentDetailViewData
import com.github.kittinunf.cookpit.PhotoDetailViewData

sealed class PhotoViewModelCommand {

    class SetPhoto(val photo: PhotoDetailViewData) : PhotoViewModelCommand()
    class SetComments(val comments: List<PhotoCommentDetailViewData>) : PhotoViewModelCommand()

}

data class PhotoViewModel(val photo: PhotoDetailViewData? = null, val comments: List<PhotoCommentDetailViewData> = listOf()) {

    fun executeCommand(command: PhotoViewModelCommand): PhotoViewModel {
        when (command) {
            is PhotoViewModelCommand.SetPhoto -> {
                return PhotoViewModel(command.photo, comments)
            }
            is PhotoViewModelCommand.SetComments -> {
                return PhotoViewModel(photo, command.comments)
            }
        }
    }

}

