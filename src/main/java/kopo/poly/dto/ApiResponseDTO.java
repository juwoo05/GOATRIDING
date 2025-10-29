// kopo/poly/dto/ApiResponseDTO.java
package kopo.poly.dto;
import lombok.*;

@Getter @Setter @Builder @AllArgsConstructor @NoArgsConstructor
public class ApiResponseDTO<T> {
    private boolean success;
    private String message;
    private T data;

    public static <T> ApiResponseDTO<T> ok(T data){
        return ApiResponseDTO.<T>builder().success(true).message("OK").data(data).build();
    }
    public static <T> ApiResponseDTO<T> fail(String msg){
        return ApiResponseDTO.<T>builder().success(false).message(msg).data(null).build();
    }
}

